extends SceneTree


var list_user:Array
# 작업 리스트
var task_stack:Array


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
	task_stack.push_back(('userJoin: '+str(id)).to_utf8())
#	send_all(('userJoin: '+str(id)).to_utf8())


func _leave(id,code,reason="No reason"):
	list_user.erase(id)
	task_stack.push_back(('userOut: '+str(id)).to_utf8())
#	send_all(('userOut: '+str(id)).to_utf8())


func _received(id):
	task_stack.push_back(wss.get_peer(id).get_packet())
#	send_all(wss.get_peer(id).get_packet())


func send_all(data):
	for user in list_user:
		wss.get_peer(user).put_packet(data)


func _idle(delta):
	wss.poll()
	for i in task_stack.size():
		send_all(task_stack.pop_front())
