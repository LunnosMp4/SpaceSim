extends Control

var notification_scene = preload("res://Scenes/Notification.tscn")
var notifications = []

func notify(text):
	var notification_instance = notification_scene.instantiate()
	notification_instance.get_node("CanvasLayer/Panel/Label").text = text

	# Position the notification
	var y = 20
	for notification in notifications:
		y += notification.get_rect().size.y + 5
		
	var panel = notification_instance.get_node("CanvasLayer/Panel")
	panel.set_position(Vector2(get_viewport_rect().size.x - panel.get_rect().size.x - 20, y))

	var animation_player = notification_instance.get_node("AnimationPlayer")
	animation_player.play("Fade")

	notifications.append(notification_instance)
	add_child(notification_instance)

	var timer = notification_instance.get_node("Timer")
	timer.start()

	# Connect the timer's timeout signal to remove the notification
	timer.connect("timeout", Callable(self, "_on_Notification_timeout"))

func _on_Notification_timeout():
	if notifications.size() == 0:
		return

	var notification_instance = notifications.pop_front() 
	notification_instance.queue_free()

	for i in range(notifications.size()):
		var notification = notifications[i]
		var y = 20
		for j in range(i):
			y += notifications[j].get_rect().size.y + 5
		var panel = notification.get_node("CanvasLayer/Panel")
		panel.set_position(Vector2(get_viewport_rect().size.x - panel.get_rect().size.x - 20, y))
