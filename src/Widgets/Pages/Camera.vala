/* Camera.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Camera.ui")]
    public class Pages.Camera : Page {
        [GtkChild]
        private unowned Gtk.Label status_label;
        [GtkChild]
        private unowned Gtk.Button update_button;
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
            update_camera_status ();

            bind_property ("camera-available",
                start_button, "sensitive",
                SYNC_CREATE
            );

            bind_property ("session-active",
                close_button, "sensitive",
                SYNC_CREATE
            );

            update_button.clicked.connect (update_camera_status);
            start_button.clicked.connect (on_start_button_clicked);
        }

        private void update_camera_status () {
            camera_available = portal.is_camera_present ();
            if (camera_available) {
                status_label.add_css_class ("success");
                status_label.label = "Available";
            }
            else {
                status_label.add_css_class ("error");
                status_label.label = "Unavailable";
            }
        }

        private void on_start_button_clicked () {
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
            portal.access_camera.begin (
                parent,
                NONE,
                null,
                callback
            );
        }

        private void on_close_button_clicked () {
            session_active = false;
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                session_active = portal.access_camera.end (res);
            }
            catch (Error e) {
                critical (e.message);
            }
        }
    }
}
