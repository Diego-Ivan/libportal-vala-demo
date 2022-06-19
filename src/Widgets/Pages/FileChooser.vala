/* FileChooser.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/FileChooser.ui")]
    public class Pages.FileChooser : Page {
        [GtkChild]
        private unowned Gtk.Entry open_title_entry;
        [GtkChild]
        private unowned Gtk.Entry save_title_entry;
        [GtkChild]
        private unowned Gtk.Entry text_entry;
        [GtkChild]
        private unowned Gtk.Switch multiple_switch;
        [GtkChild]
        private unowned Gtk.Label open_response;
        [GtkChild]
        private unowned Adw.PreferencesGroup response_group;

        public FileChooser (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        construct {
        }

        [GtkCallback]
        public void on_open_button_clicked () {
            string title = open_title_entry.text;
            bool multiple = multiple_switch.active;
            response_group.visible = true;
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);

            portal.open_file.begin (
                parent,
                title,
                null,
                null,
                null,
                multiple? Xdp.OpenFileFlags.MULTIPLE : Xdp.OpenFileFlags.NONE,
                null,
                callback
            );
        }

        [GtkCallback]
        public void on_save_button_clicked () {
            string title = save_title_entry.text;

            if (title == "") {
                title = save_title_entry.placeholder_text;
            }

            var dialog = new Gtk.FileChooserNative (
                title,
                get_native () as Gtk.Window,
                Gtk.FileChooserAction.SAVE,
                null,
                null
            );

            string[] encoding_options = {
                "current",
                "iso8859-15",
                "utf-16"
            };

            string[] encoding_titles = {
                "Current Locale (UTF-8)",
                "Western (ISO-8859-15)",
                "Unicode (UTF-16)"
            };

            dialog.add_choice ("encoding",
                "Encoding",
                encoding_options,
                encoding_titles
            );

            dialog.response.connect ((res) => {
                if (res == Gtk.ResponseType.ACCEPT) {
                    string path = dialog.get_file ().get_path ();
                    bool result = false;

                    try {
                        result = GLib.FileUtils.set_contents (path, text_entry.text);
                    }
                    catch (Error e) {
                        critical (e.message);
                    }

                    if (!result) {
                        warning ("Error writing file");
                    }
                }
            });

            dialog.show ();
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            GLib.Variant info;
            open_response.label = "";
            try {
                info = portal.open_file.end (res);
                Variant uris = info.lookup_value ("uris", VariantType.STRING_ARRAY);
                string[] files = uris as string[];

                for (int i = 0; i < files.length; i++) {
                    string response = "%s\n".printf (files[i]);
                    open_response.label += response;
                }

                open_response.remove_css_class ("error");
            }
            catch (Error e) {
                open_response.add_css_class ("error");
                open_response.label = e.message;
                critical (e.message);
            }
        }
    }
}
