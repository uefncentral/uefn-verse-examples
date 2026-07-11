# Custom Event System
# Creates a custom event subscription system that integrates with trigger devices to handle asynchronous callbacks and event signaling. The system allows components to subscribe to custom events and aut
# Difficulty: advanced  |  UEFN: Verse 1
# ✅ Verified against Epic's official Verse digest by UEFN Central.
# Full guide + one-click generate: https://uefncentral.com/library/nn6n-helper-scripts-custom-listenable?ref=github

my_callback<internal>(t:type) := class:
    Callback<internal> : t -> void
    SpawnAwait<internal> : type{_(:t->void)<suspends>:void}
  
    OnSignal(Agent:?agent) : void =
        spawn {SpawnAwait(Callback)}
  
  my_cancelable<internal> := class(cancelable):
    MaybeCancelable<internal> : ?cancelable = false
  
    Cancel<override>()<transacts> : void =
        if (Cancelable := MaybeCancelable?):
            Cancelable.Cancel()
  
  my_subscribable<internal>(t:type) := class(listenable(t), signalable(t)):
    Event<private> : event(t) = event(t){}
  
    Await<override>()<suspends> : t =
        Event.Await()
  
    GetProxyTrigger<private>()<transacts> : ?trigger_device =
        var ProxyTrigger : ?trigger_device = false
        for (Actor : GetCreativeObjectsWithTag(subscribable_proxytrigger{})):
            if (Trigger := trigger_device[Actor]):
                set ProxyTrigger = option{Trigger}
        ProxyTrigger
  
    Signal<override>(Val:t) : void =
        if (Trigger := GetProxyTrigger()?):
            Trigger.Trigger()
        spawn {SleepSignal(Val)}
  
    SleepSignal<private>(Val:t)<suspends> : void =
        Sleep(0.0)
        Event.Signal(Val)
  
    SpawnAwait<private>(Callback:t -> void)<suspends> : void =
        Callback(Await())
  
    Subscribe<override>(Callback:t -> void)<transacts> : cancelable =
        var Cancelable : my_cancelable = my_cancelable{}
        if (Trigger := GetProxyTrigger()?):
            set Cancelable = my_cancelable{MaybeCancelable := option{Trigger.TriggeredEvent.Subscribe(my_callback(t){Callback := Callback, SpawnAwait := SpawnAwait}.OnSignal)}}
        Cancelable
  
  subscribable_proxytrigger<public> := class(tag){}
  
  my_class<public> := class:
    OnCustomEvent<public>() : listenable(int) = OnCustomEventSignaler
    OnCustomEventSignaler<private> : my_subscribable(int) = my_subscribable(int){}
  
    SomeInternalMethod<internal>(Number:int) : void =
        OnCustomEventSignaler.Signal(Number)