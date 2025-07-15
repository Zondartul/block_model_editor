extends Node

var inspector_param_widgets = {}

func populate_inspector_params():
	var params = inspector_cur_object.generator.get_param_list();
	for p in params:
		var lbl = Label.new()
		lbl.text = p.name;
		n_inspector_grid.add_child(lbl);
		var entry;
		# per-type settings
		match p.type:
			"float":
				entry = SpinBox.new()
				entry.step = 0.01;
			"int":
				entry = SpinBox.new()
				entry.step = 1.0;
				entry.rounded = true;
			"bool":
				entry = CheckBox.new()
			_:
				error("Internal: Inspector: unexpected param type "+str(p.type));
				close_inspector();
				return;
		# per-entry method settings
		match entry.get_class():
			"SpinBox":
				entry.value_changed.connect(on_inspector_changed);
				if p.range:
					entry.min_value = p.range[0];
					entry.max_value = p.range[1];
					entry.allow_greater = false;
					entry.allow_lesser = false;
			"CheckBox":
				entry.toggled.connect(on_inspector_changed);
			_:
				error("Internal: Inspector: unexpected widget type");
				close_inspector();
				return;
		inspector_param_widgets[p.name] = entry; # record the param-widget pair
		n_inspector_grid.add_child(entry);
	inspector_ignore_signals = true;
	update_inspector_params();
	inspector_ignore_signals = false;

func depopulate_inspector_params():
	inspector_param_widgets.clear()
	var chs = n_inspector_grid.get_children().duplicate()
	for ch in chs: 
		n_inspector_grid.remove_child(ch);
		ch.queue_free();
