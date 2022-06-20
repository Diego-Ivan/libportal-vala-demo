/* TrashFile.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.trash_file.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/TrashFile.ui")]
    public class Pages.TrashFile : Page {
        [GtkChild]
        private unowned Gtk.Button open_button;
        [GtkChild]
        private unowned Gtk.Label result_label;
        private string path;

        public TrashFile (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        construct {
            open_button.clicked.connect (on_open_button_clicked);
        }

        private void on_open_button_clicked () {
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
            // See the FileChooser.vala page to see more information on the OpenFile portal, in case you need it
            portal.open_file.begin (
                parent,
                "Select a file to trash",
                null,
                null,
                null,
                NONE,
                null,
                file_callback
            );
        }

        public void file_callback (GLib.Object? obj, GLib.AsyncResult res) {
            GLib.Variant info;
            try {
                info = portal.open_file.end (res);
                Variant uris = info.lookup_value ("uris", VariantType.STRING_ARRAY);
                string[] files = uris as string[];

                if (files[0] != "") {
                    path = GLib.Filename.from_uri (files[0]);

                    // Trash file petition
                    portal.trash_file.begin (
                        path, // Path of the file selected
                        null, // Cancellable, we're using none
                        callback // Callback of the function
                    );
                }
            }
            catch (Error e) {
                critical (e.message);
            }
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool result;
            result_label.visible = true;
            result_label.remove_css_class ("error");
            result_label.remove_css_class ("success");

            try {
                // A boolean that will tell us if our request was successful
                result = portal.trash_file.end (res);

                if (result) {
                    result_label.label = "File was successfully trashed";
                    result_label.add_css_class ("success");
                }
                else {
                    result_label.label = "File was not trashed";
                    result_label.add_css_class ("error");
                }
            }
            catch (Error e) {
                critical (e.message);
                result_label.label = e.message;
                result_label.add_css_class ("error");
            }
        }
    }
}
