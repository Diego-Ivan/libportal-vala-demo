/* Camera.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.access_camera.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Camera.ui")]
    public class Pages.Camera : Page {
        [GtkChild]
        private unowned Gtk.Label status_label;
        [GtkChild]
        private unowned Gtk.Button start_button;
        [GtkChild]
        private unowned Gtk.Button close_button;

        public bool camera_available { get; private set; }
        public bool session_active { get; private set; default = false; }

        public Camera (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        construct {
            on_update_button_clicked ();

            bind_property ("camera-available",
                start_button, "sensitive",
                SYNC_CREATE
            );

            bind_property ("session-active",
                close_button, "sensitive",
                SYNC_CREATE
            );
        }

        [GtkCallback]
        private void on_update_button_clicked () {
            // https://valadoc.org/libportal/Xdp.Portal.is_camera_present.html
            camera_available = portal.is_camera_present (); // Checking camera availability
            if (camera_available) {
                status_label.add_css_class ("success");
                status_label.label = "Available";
            }
            else {
                status_label.add_css_class ("error");
                status_label.label = "Unavailable";
            }
        }

        [GtkCallback]
        private void on_start_button_clicked () {
            // https://valadoc.org/libportal/Xdp.Parent.html
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
            portal.access_camera.begin (
                parent, // Xdp.Parent
                NONE, // Flags for the request. Currently, NONE is the only value
                null, // Cancellable. We are using none
                callback // Callback for the function, in which we will receive the results of the petition.
            );
        }

        [GtkCallback]
        private void on_close_button_clicked () {
            session_active = false;
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                session_active = portal.access_camera.end (res);
                // If the response you obtained was positive, now you can call Xdp.Portal.open_pipewire_remote_for_camera ()
                // https://valadoc.org/libportal/Xdp.Portal.open_pipewire_remote_for_camera.html
            }
            catch (Error e) {
                critical (e.message);
            }
        }
    }
}
