extends SceneTree


var list_user:Array


var wss:WebSocketServer


func _init():
	wss=WebSocketServer.new()
	wss.connect("client_connected",self,'user_join')
	wss.connect("data_received",self,'_received')
	wss.connect("client_disconnected",self,'_leave')
	if wss.listen(12000) != OK:
		print('Server Create Failed')
	else:
		print('Server opened!')


func user_join(id,proto):
	list_user.append(id)
	send_all(('userJoin: '+str(id)).to_utf8())


func _leave(id,code,reason="No reason"):
	list_user.erase(id)
	send_all(('userOut: '+str(id)).to_utf8())


func _received(id):
	send_all(wss.get_peer(id).get_packet())


func send_all(data):
	for user in list_user:
		wss.get_peer(user).put_packet(data)


func _idle(delta):
	wss.poll()
