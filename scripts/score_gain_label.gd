extends Node2D

var amount = 2
var multiplier = 3

func set_labels() -> void:
	$AmountHolder/Amount.text = str(amount)
	if multiplier > 1:
		$MultiplierHolder/Multiplier.text = "X" + str(multiplier)
	else:
		$MultiplierHolder/Multiplier.text = ""
	$MultiplierHolder/Multiplier.position = $AmountHolder/Amount.position + Vector2($AmountHolder/Amount.get_content_width() + 2.0, 0.0)

func combine():
	$AmountHolder/Amount.text = str(amount * multiplier)
