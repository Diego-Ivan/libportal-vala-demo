/* FileChooser.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.FileChooser : Page {
        private Gtk.Entry open_title_entry;
        private Gtk.Entry save_title_entry;
        private Gtk.Entry text_entry;
        private Gtk.Switch multiple_switch;
        private Gtk.Button open_button;
        private Gtk.Button save_button;
        private Gtk.Label open_response;

        public FileChooser (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "File Chooser"
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
            save_button.clicked.connect (on_save_button_clicked);
        }

        public void on_open_button_clicked () {
            string title = open_title_entry.text;
            bool multiple = multiple_switch.active;
            Xdp.Parent parent = Xdp.parent_new_gtk (parent_window);

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

        public void on_save_button_clicked () {
            string title = save_title_entry.text;

            if (title == "") {
                title = save_title_entry.placeholder_text;
            }

            var dialog = new Gtk.FileChooserNative (
                title,
                parent_window,
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
                        warning ("Error writting file");
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

        public void save_callback (GLib.Object? obj, GLib.AsyncResult res) {
        }

        public override void build_ui () {
           try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/FileChooser.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                open_title_entry = builder.get_object ("open_title_entry") as Gtk.Entry;
                save_title_entry = builder.get_object ("save_title_entry") as Gtk.Entry;
                text_entry = builder.get_object ("text_entry") as Gtk.Entry;
                multiple_switch = builder.get_object ("multiple_switch") as Gtk.Switch;
                open_button = builder.get_object ("open_button") as Gtk.Button;
                save_button = builder.get_object ("save_button") as Gtk.Button;
                open_response = builder.get_object ("open_response") as Gtk.Label;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }

    }
}
