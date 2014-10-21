app = angular.module("phoenixSocket", [])

app.factory "Socket",  ($q, $rootScope, $log) ->
  $log.debug("socket loaded")
  underlyingSocket = new Phoenix.Socket("ws://" + location.host +  "/ws")
  connectedChannels = {}
  listenersByChannel = {}

  return {
    join: (requestor, channel, topic) ->
      chanKey = "#{channel}:#{topic}"
      $log.debug "got a join request from:"
      $log.debug requestor
      $log.debug("trying to join #{chanKey}")
      defer = $q.defer()

      # add listener
      listenersByChannel[chanKey] = [] unless listenersByChannel[chanKey]
      listenersByChannel[chanKey].push requestor
      $log.debug "listeners by channel is now:"
      $log.debug listenersByChannel

      if connectedChannels[chanKey]
        defer.resolve(connectedChannels[chanKey])
      else
        underlyingSocket.join channel, topic, {}, (chan) ->
          connectedChannels[chanKey] = chan
          defer.resolve(chan)

      defer.promise

    on: (chan, eventName, callback) ->
      chan.on eventName, (message) ->
        $rootScope.$apply(callback(message))

    send: (chan, eventName, payload) ->
      chan.send eventName, payload

    leave: (chan, requestor, message) -> 
      chanKey = "#{chan.channel}:#{chan.topic}"
      listenersByChannel[chanKey] = listenersByChannel[chanKey].filter (r) -> r != requestor
      if listenersByChannel[chanKey].length == 0
        delete listenersByChannel[chanKey]
        delete connectedChannels[chanKey]
        chan.leave message
  }
