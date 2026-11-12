import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Covers the normal Omarchy wallpaper with a fixed image while a monitor shows
// one particular workspace. It sits on the Bottom layer, above omarchy's
// Background layer and below windows and the bar, and takes no input, so
// double-clicking the desktop still reaches the stock background switcher.
Item {
  id: root

  property var shell: null

  // Omarchy gives each monitor its own block of ten workspaces (1-10, 11-20,
  // 21-30, ...), so "workspace 2" is the second slot of whichever block.
  readonly property int slot: 2
  readonly property string image: Quickshell.env("HOME") + "/dotfiles/wallpaper/cheatsheet.png"
  readonly property color fill: "#1a1b26"

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      readonly property var monitor: Hyprland.monitorFor(modelData)
      readonly property int workspaceId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1

      screen: modelData
      visible: workspaceId > 0 && (workspaceId - 1) % 10 + 1 === root.slot
      anchors { top: true; bottom: true; left: true; right: true }
      color: root.fill

      WlrLayershell.namespace: "workspace-background"
      WlrLayershell.layer: WlrLayer.Bottom
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      exclusionMode: ExclusionMode.Ignore
      mask: Region {}

      // Fit rather than crop, so the edge columns survive on a 16:10 laptop
      // screen; the letterbox uses the image's own background color.
      Image {
        anchors.fill: parent
        source: "file://" + root.image
        fillMode: Image.PreserveAspectFit
        sourceSize.width: Math.ceil(panel.width * panel.screen.devicePixelRatio)
        sourceSize.height: Math.ceil(panel.height * panel.screen.devicePixelRatio)
        asynchronous: true
        cache: false
        smooth: true
        mipmap: true
      }
    }
  }
}
