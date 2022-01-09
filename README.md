<div align="center">

# Libportal Vala Demo

**This project is not affiliated with the Flatpak organization, nor with the upstream Libportal project**

</div>

This is a demo for the [Libportal](https://github.com/flatpak/libportal) written in the [Vala Programming Language](https://vala-project.org)

## Portals Available

- [x] Accounts (User information)
- [x] Background
- [ ] Camera
- [x] Color Picker
- [x] Email
- [x] File Chooser (Open and Save Files)
- [ ] Location
- [x] Notification
- [x] Open URI
- [ ] Print File
- [ ] Remote Desktop
- [ ] Screencast
- [x] Screenshot
- [ ] Session (inhibit, monitor)
- [ ] Spawn
- [x] Trash File
- [ ] Updates
- [x] Wallpaper

## Install and Running

### GNOME Builder

The recommended way of running this project is through Flatpak and GNOME Builder. Clone the project and run. Requires the `org.gnome.Platform` runtime, from the master branch. You can get it from the GNOME Nightly Flatpak remote. Libportal and the GTK4 backend will be built with the project.

To install, use the *Export as package* feature (available in the top bar omniarea) and open the `.flatpak` double-clicking, and install.

### Other

This project requires the following dependencies:

```
gtk4
libadwaita-1
libportal
libportal-gtk4
```

Build using the Meson Build System:

```sh
meson builddir --prefix=/usr
cd builddir
ninja
./src/libportal-vala-sample
```

To install, run in the `builddir`:

```sh
sudo ninja install
```
