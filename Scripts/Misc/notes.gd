extends CanvasLayer


var Dialogues = [
	"",
	"6 , 7, 6, 7, 6",
	"6, 9, 6, 9, 6",
	"9, 10, 10, 10, 1"
]

@onready var text = $Label


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	text.text = Dialogues[0]
	Global.ShowNote.connect(_show_interact_ui)
	Global.HideUi.connect(_hide_ui)

func _show_interact_ui(id: int):
	show()
	text.text = Dialogues[id]

func _hide_ui():
	text.text = Dialogues[0]
	hide()
