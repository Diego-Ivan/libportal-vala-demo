/* Wallpaper.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.set_wallpaper.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Wallpaper.ui")]
    public class Pages.Wallpaper : Page {
        [GtkChild]
        private unowned Adw.ComboRow options_combo;
        [GtkChild]
        private unowned Gtk.Switch preview_switch;
        [GtkChild]
        private unowned Gtk.Label response_label;

        private Xdp.WallpaperFlags flags;
        private string image_path;

        public Wallpaper (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        [GtkCallback]
        private void on_open_button_clicked () {
            var string_list = options_combo.model as Gtk.StringList;
            string selected = string_list.get_string (options_combo.selected);

            switch (selected) {
                case "Wallpaper":
                    flags = Xdp.WallpaperFlags.BACKGROUND;
                    break;

                case "Lockscreen":
                    flags = Xdp.WallpaperFlags.LOCKSCREEN;
                    break;

                case "Both":
                    flags = Xdp.WallpaperFlags.BACKGROUND | Xdp.WallpaperFlags.LOCKSCREEN;
                    break;

                default:
                    flags = Xdp.WallpaperFlags.BACKGROUND;
                    break;
            }

            if (preview_switch.active) {
                flags = flags | Xdp.WallpaperFlags.PREVIEW;
            }

            var filters = new Gtk.FileFilter () {
                name = "Image"
            };

            filters.add_suffix ("png");
            filters.add_suffix ("jpeg");
            filters.add_suffix ("jpg");

            var filechooser = new Gtk.FileChooserNative (
                "Select an image file",
                get_native () as Gtk.Window,
                OPEN,
                null,
                null
            );

            filechooser.add_filter (filters);
            filechooser.response.connect ((res) => {
                if (res == Gtk.ResponseType.ACCEPT) {
                    image_path = filechooser.get_file ().get_uri ();

                    // https://valadoc.org/libportal/Xdp.Parent.html
                    Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
                    portal.set_wallpaper.begin (
                        parent, // Xdp.Parent
                        image_path, // Path of the image that will be set as wasllpaper
                        flags, // Flags of the petition, whether is should set as BACKGROUND, LOCKSCREEN, if it should display a PREVIEW or NONE
                        null, // Cancellable, using none
                        callback // Callback of the function, in which we will receive its result.
                    );
                }
            });

            filechooser.show ();
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool result;

            response_label.remove_css_class ("success");
            response_label.remove_css_class ("error");

            try {
                // We will receive a boolean that will indicate if our petition was successful
                result = portal.set_wallpaper.end (res);

                if (result) {
                    response_label.label = "Wallpaper was properly set";
                    response_label.add_css_class ("success");
                }
                else {
                    response_label.label = "Failed setting the wallpaper";
                    response_label.add_css_class ("error");
                }
            }
            catch (Error e) {
                critical (e.message);

                response_label.label = e.message;
                response_label.add_css_class ("error");
            }
        }
    }
}
