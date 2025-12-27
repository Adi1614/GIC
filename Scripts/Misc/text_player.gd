extends CanvasLayer

@onready var text: Label = $Label
@onready var UI_sfx = $"../UIsfx"

# ===============================
# TEXT DATABASE
# ===============================
var texts := {
	1: {#level 2
		"text": "Play Correct Sound to Turn on the Power",
		"one_time": false
	},
	2: {#common
		"text": "This is a dead end",
		"one_time": false
	},
	3:{#level 1 storyline
		"text": "The lab went dark… Whatever that thing is, it reacts to sound. I must find the Horn, It should be here somewhere. I think Hiding under the tables will be safe.",
		"one_time":true
	},
	4:{
		"text": "Found it, It’s tunable… That'll help me get out of here. If the logs are right, the wrong sound could make it worse.",
		"one_time":true
	},
	5:{
		"text": "The door is closed, I think i need to find the correct settings on my Horn to open it",
		"one_time":false
	},
	6:{#common
		"text": "Play the right sound to Open Door.",
		"one_time":false
	},
	7:{#level 1 story end
		"text":"It worked. The sound stunned it… but not for long. And it seems to have limited uses. I should get out of here.",
		"one_time":true
	},
	8:{#level 2
		"text" : "I need to get out of this facility. There has to be an exit somewhere on this floor.",
		"one_time" : true
	},
	9:{
		"text" : "This is it… the exit from this floor. The door override is still active. I need to find and turn on the 3 machines on this floor, they probably need specific sounds to activate too.",
		"one_time" : true
	},
	10:{#level 3
		"text" : "[LOUD NOISE]  What is that noise?!   It knows where I am. I NEED TO RUN!",
		"one_time" : true
	},
	11:{#cutscene
		"text": "Control to all personnel… the resonance chamber is destabilizing.",
		"one_time": true
	},
	12:{#cutscene
		"text": "We’re losing containment— sound dampeners are failing!",
		"one_time": true
	},
	13:{#cutscene
		"text": "Repeat, the subject is reacting to— [STATIC] —it’s learning—",
		"one_time": true
	},
	14:{#cutscene
		"text": "Why did it stop moving?",
		"one_time": true
	},
	15:{#cutscene
		"text": "Why did it stop—",
		"one_time": true
	},
	16:{#cutscene
		"text": "OH GOD—",
		"one_time": true
	},
	17:{#cutscene
		"text": "…All units… respond… please…",
		"one_time": true
	},
	18:{#Level2
		"text": "All 3 machines not activated yet",
		"one_time": false
	},
	19:{#Level3
		"text": "CALL FOR HELP!!!",
		"one_time": false
	},
	20:{#Level3
		"text": "Horn Is Malfunctioning",
		"one_time": false
	}
}

var current_text_id := -1

func _ready():
	text.text = ""
	Global.ShowUi.connect(_on_show_ui)
	Global.HideUi.connect(_on_hide_ui)
	

func _on_show_ui(id: int):
	if UI_sfx and not texts[id].one_time:
		UI_sfx.play()
	
	if not texts.has(id):
		return

	# One-time protection
	if texts[id].one_time:
		if Global.dialogue_completed.get(id, false):
			return
		Global.dialogue_completed[id] = true

	current_text_id = id
	text.text = texts[id].text

func _on_hide_ui():
	text.text = ""
	current_text_id = -1
