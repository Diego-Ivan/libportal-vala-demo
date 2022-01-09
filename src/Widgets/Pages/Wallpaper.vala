/* Wallpaper.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Wallpaper : Page {
        private Adw.ComboRow options_combo;
        private Gtk.Switch preview_switch;
        private Gtk.Button open_button;
        private Gtk.Label response_label;
        private Xdp.WallpaperFlags flags;
        private string image_path;

        public Wallpaper (Xdp.Portal portal_) {
            Object (
                portal: portal_,
                title: "Wallpaper"
            );
        }

        construct {
            build_ui ();

            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );

            open_button.clicked.connect (on_open_button_clicked);
        }

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

                    Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
                    portal.set_wallpaper.begin (
                        parent,
                        image_path,
                        flags,
                        null,
                        callback
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

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Wallpaper.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                options_combo = builder.get_object ("options_combo") as Adw.ComboRow;
                preview_switch = builder.get_object ("preview_switch") as Gtk.Switch;
                open_button = builder.get_object ("open_button") as Gtk.Button;
                response_label = builder.get_object ("response_label") as Gtk.Label;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }

    }
}
