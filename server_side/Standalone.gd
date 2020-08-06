extends SceneTree


var list_user:Dictionary
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
		print('------------------------------')
		for address in IP.get_local_addresses():
			if address.find('.')+1:
				print(address)
		print('------------------------------')


func user_join(id:int,proto):
	list_user[id]=''
#	send_all(('userName: '+str(id)).to_utf8())


func _leave(id:int,code,reason="No reason"):
	var who_is=list_user[id]
	list_user.erase(id)
	send_all(('userOut: '+who_is).to_utf8())


func _received(id):
	var packet:=wss.get_peer(id).get_packet()
	var received_string=packet.get_string_from_utf8()
	if(received_string.find('userName:')==0):
		list_user[id]=received_string.substr(9)
		send_all(('userJoin: '+list_user[id]).to_utf8())
		return
	send_all(packet)


func send_all(data:PoolByteArray):
	for user in list_user:
		wss.get_peer(user).put_packet(data)


func _idle(delta):
	if(wss):
		wss.poll()


func _exit_tree():
	print('사용자 요청에 의한 프로그램 종료')
