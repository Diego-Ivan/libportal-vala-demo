/* FileChooser.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.open_file.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/FileChooser.ui")]
    public class Pages.FileChooser : Page {
        [GtkChild]
        private unowned Adw.EntryRow open_title_entry;
        [GtkChild]
        private unowned Adw.EntryRow save_title_entry;
        [GtkChild]
        private unowned Adw.EntryRow text_entry;
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
            response_group.visible = true;

            // https://valadoc.org/libportal/Xdp.Parent.html
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);

            portal.open_file.begin (
                parent, // Xdp.Parent
                open_title_entry.text, // Title of the dialog
                null, // Filters as Variant. Using none
                null, // Current filter as Variant, using none
                null, // Current filter as choices, using none
                multiple_switch.active? Xdp.OpenFileFlags.MULTIPLE : Xdp.OpenFileFlags.NONE, // Flags for the call, whether its multiple files or a single one
                null, // Cancellable, using none
                callback // Callback of the function in which we will receive the output of our petition
            );
        }

        [GtkCallback]
        public void on_save_button_clicked () {
            // Gtk Provides the FileChooserNative API, an easy to use filechooser portal
            var dialog = new Gtk.FileChooserNative (
                save_title_entry.text, // Title of the dialog
                get_native () as Gtk.Window, // Window parent
                Gtk.FileChooserAction.SAVE, // Action, whether its SAVE or OPEN
                null, // Accept button label, using the default
                null // Cancel button label, using the default
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
                    string path = dialog.get_file ().get_path (); // Obtaining the file that was given to us
                    bool result = false;

                    try {
                        result = GLib.FileUtils.set_contents (path, text_entry.text); // Writing to such file
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
            GLib.Variant info; // Result as a Variant
            open_response.label = "";
            try {
                info = portal.open_file.end (res);
                Variant uris = info.lookup_value ("uris", VariantType.STRING_ARRAY); // Lookup for the URIs of the files
                string[] files = (string[]) uris;

                for (int i = 0; i < files.length; i++) {
                    string response = "%s\n".printf (files[i]);
                    // displaye the URIs on screen
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
