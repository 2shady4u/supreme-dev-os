extends TabContainer

func set_current_tab(type : int):
	var index := 0
	for child in get_children():
		if child.tab_type == type:
			child.update_tab()
			current_tab = index

			return
		index += 1
