import
  psutil,
  times,
  strutils,
  strformat,
  osproc,
  os,
  json

const
  FG_NORMAL = "\x1b[0m"
  BG_NORMAL = "\x1b[49m"
  FG_RED = "\x1b[38;2;224;108;117m"
  BG_RED = "\x1b[40;2;224;108;117m"
  FG_GREEN = "\x1b[38;2;152;195;121m"
  BG_GREEN = "\x1b[40;2;152;195;121m"
  FG_BLUE = "\x1b[38;2;113;151;231m"
  BG_BLUE = "\x1b[40;2;113;151;231m"
  FG_PURPLE = "\x1b[38;2;167;122;196m"
  BG_PURPLE = "\x1b[40;2;167;122;196m"
  FG_YELLOW = "\x1b[38;2;229;192;123m"
  BG_YELLOW = "\x1b[40;2;229;192;123m"
  CPU_GREEN = "\x1b[38;2;22;206;40m"
  CPU_YELLOW = "\x1b[38;2;215;182;32m"
  CPU_RED = "\x1b[38;2;224;108;117m"

proc bytes_to_human(bytes: int, includeSpace: bool = false): string =
  formatSize(bytes, decimalSep='.', prefix=bpColloquial, includeSpace=includeSpace)

proc sep_widget(color: string = FG_NORMAL): string =
  result = "$1$2" % [color, " | "]

proc ram_widget(color: string = FG_PURPLE): string =
  let ramHuman = bytes_to_human(virtualMemory().used, true).split(" ")
  let space = ramHuman[0].parseFloat().formatFloat(ffDecimal, 2)
  let sufix = ramHuman[1]
  result = "$1RAM: $2$3" % [color, space, sufix]

proc ssd_widget(color: string = FG_YELLOW): string =
  let ssdHuman = bytes_to_human(diskUsage("/").free, true).split(" ")
  let space = ssdHuman[0].parseFloat().formatFloat(ffDecimal, 2)
  let sufix = ssdHuman[1]
  result = "$1SSD: $2$3" % [color, space, sufix]

proc time_widget(color: string = FG_RED): string =
  result = "$1$2" % [color, getTime().format("hh:mm:ss tt")]

proc temp_widget(): string =
  let data = execCmdEx("sensors -A -j acpitz-acpi-0")
  let jsonData = data.output.parseJson()
  let temp = jsonData["acpitz-acpi-0"]["temp1"]["temp1_input"].getFloat().int
  if temp <= 45:
    result = "$1CPU: $2°C" % [CPU_GREEN, $temp]
  elif temp >= 46 and temp <= 69:
    result = "$1CPU: $2°C" % [CPU_YELLOW, $temp]
  else:
    result = "$1CPU: $2°C" % [CPU_RED, $temp]

when isMainModule:
  while true:
    let nimBar = @[
      sep_widget(),
      temp_widget(),
      sep_widget(),
      ssd_widget(),
      sep_widget(),
      ram_widget(),
      sep_widget(),
      time_widget(),
      sep_widget()
    ].join("")
    discard execProcess("xsetroot", args=["-name", nimBar], options={poUsePath})
    sleep(1000)
