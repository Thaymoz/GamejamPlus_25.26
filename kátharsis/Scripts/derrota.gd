extends Control


func _on_btn_denovo_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_btn_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
