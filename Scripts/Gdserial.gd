extends Node

var serial: GdSerial
var direction := "IDLE"
var button_pressed := false

func _ready():
	serial = GdSerial.new()   # <- OBRIGATÓRIO (senão é NIL !!!)

	var ports = serial.list_ports()
	print("Portas disponíveis:", ports)

	serial.set_port("COM5")        # ajuste conforme o seu PC
	serial.set_baud_rate(9600)

	if serial.open():              # ← aqui funciona
		print("Serial conectado!")
	else:
		print("Falha ao abrir porta serial!")


func _process(delta):
	if serial == null:
		return
	
	var line = serial.readline()

	if line == null or line == "":
		return

	line = line.strip_edges()
	print("RX:", line)

	var parts = line.split(",")
	if parts.size() < 2:
		return

	direction = parts[0]
	button_pressed = parts[1] == "1"
