extends Node2D


@rpc("any_peer", "call_local")
func interact(user: Node) -> void:
	print(user, "interacting with button")
	var path = "../" + $"..".interact_with
	print(path)
	var object = get_node_or_null(path)
	print(object)
	if object != null and object.has_method("interact"):
		print("here")
		object.rpc("interact")


@rpc("any_peer", "call_local")
func send_interaction() -> void:
	# changes to button to send to everyone
	print('sendInteraction')


func hover() -> void:
	$"../Label".visible = true
	
	
func unhover() -> void:
	$"../Label".visible = false
