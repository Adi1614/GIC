extends CanvasLayer


var Dialogues = [
	"",
	"Machine 1 Activation Code:
		6, 7, 6, 7, 6",
	"Machine 1 Activation Code: 6, 9, 6, 9, 6",
	"Machine 1 Activation Code: 9, 10, 10, 10, 1",
	"Correct Sequence for  Opening Door: 3, 2, 4, 1, 5,
	 
	IF YOU NEED HELP: 10, 10, 10, 10, 0",
	"During the Experiments, it was noticed that the creature behaved quite mildly or even got stunned when this sound was played.
	Sound Config (Play the Config Once to save it to Notes):
		Pitch: 5,
		Distortion: 10,
		Delay: 10,
		Phaser: 7,
		Compressor: 0
		"
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
