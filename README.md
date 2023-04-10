https://user-images.githubusercontent.com/36821133/230897709-ff770423-e684-4d44-a603-16e644ef424d.mp4

# Godot Array Modifier

This plugin recreates the functionality of the Array Modifier from Blender 3D.

## Installation

To use the plugin in your own project copy all the files in the `addons/` folder to the `addons/` folder of your project and enable the plugin in Godot settings. Check [Godot Docs: Installing plugins](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html) for complete instructions.

## Tutorial

Add the `ArrayModifier` node to your project, then add nodes as children. All of the children will be repeated according to the modifier's settings.

The plugin consists of 3 settings:

* **Repeat Levels**: each repeat level duplicates everything the Array Modifier has created by far. The number at each level indicates the number of repetitions.

* **Repeat Offsets**: the 3D distance between repeated elements. The number of offsets is the same as the number of levels.

* **Force Refresh**: Setting this value will recalculate all repeated nodes. The number of copies and the distances will be updated everytime a change is made to `Repeat Levels` or `Repeat Offsets`, but any changes in the original nodes themselves will require using this setting.
