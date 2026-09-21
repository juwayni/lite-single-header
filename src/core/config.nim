## config.nim - Global editor settings and defaults
## Ports data/core/config.lua to Nim with type-safe fields and runtime configuration management.

type
  TabType* = enum
    ttSoft, ttHard

  Config* = object
    fps*: float
    maxLogItems*: int
    messageTimeout*: float
    mouseWheelScroll*: float
    fileSizeLimit*: int # MB
    ignoreFiles*: string
    symbolPattern*: string
    nonWordChars*: string
    undoMergeTimeout*: float
    maxUndos*: int
    highlightCurrentLine*: bool
    lineHeight*: float
    indentSize*: int
    tabType*: TabType
    lineLimit*: int
    projectScanRate*: float # seconds
    projectScanDepth*: int
    projectMaxFilesPerFolder*: int
    blinkPeriod*: float
    tabsAllowed*: bool

proc initConfig*(scale: float = 1.0): Config =
  Config(
    fps: 60.0,
    maxLogItems: 80,
    messageTimeout: 6.0,
    mouseWheelScroll: 50.0 * scale,
    fileSizeLimit: 10,
    ignoreFiles: r"^\.",
    symbolPattern: r"[_a-zA-Z][_a-zA-Z0-9]*",
    nonWordChars: " \t\n/\\()\"':,.;<>~!@#$%^&*|+=[]{}`?-",
    undoMergeTimeout: 0.3,
    maxUndos: 10000,
    highlightCurrentLine: true,
    lineHeight: 1.2,
    indentSize: 2,
    tabType: ttSoft,
    lineLimit: 80,
    projectScanRate: 5.0,
    projectScanDepth: 8,
    projectMaxFilesPerFolder: 2000,
    blinkPeriod: 1.3,
    tabsAllowed: true
  )

var defaultConfig* = initConfig(1.0)
