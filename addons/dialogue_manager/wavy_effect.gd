extends RichTextEffect

var bbcode = "wave" # The tag name: [wave][/wave]

func _process_custom_fx(char_fx: CharFXTransform):
	var t = Time.get_ticks_msec() / 1000.0
	var wave_height = 5.0
	var wave_speed = 12.0
	var char_offset = float(char_fx.relative_index)
	char_fx.offset.y += sin(t * wave_speed + char_offset * 0.5) * wave_height
	return true
