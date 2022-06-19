/* Location.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Location.ui")]
    public class Pages.Location : Page {
        [GtkChild]
        private unowned Shumate.SimpleMap simple_map;
        private Shumate.Map map_location {
            get {
                return simple_map.map;
            }
        }

        [GtkChild]
        private unowned Gtk.SpinButton distance_entry;
        [GtkChild]
        private unowned Gtk.SpinButton time_entry;
        [GtkChild]
        private unowned Adw.ComboRow accuracy_row;

        [GtkChild]
        private unowned Gtk.Button start_button;
        [GtkChild]
        private unowned Gtk.Button stop_button;

        [GtkChild]
        private unowned Gtk.Box result_box;
        [GtkChild]
        private unowned Gtk.Label lat_label;
        [GtkChild]
        private unowned Gtk.Label longi_label;
        [GtkChild]
        private unowned Gtk.Label alti_label;
        [GtkChild]
        private unowned Gtk.Label acc_label;
        [GtkChild]
        private unowned Gtk.Label speed_label;
        [GtkChild]
        private unowned Gtk.Label head_label;
        [GtkChild]
        private unowned Gtk.Label error_label;

        public bool monitor_active { get; private set; }

        public Location (Xdp.Portal portal_) {
            Object (
                portal: portal_,
                title: "Location"
            );
        }

        construct {
            bind_property ("monitor-active",
                start_button, "sensitive",
                SYNC_CREATE | INVERT_BOOLEAN
            );

            bind_property ("monitor-active",
                stop_button, "sensitive",
                SYNC_CREATE
            );

            var registry = new Shumate.MapSourceRegistry.with_defaults ();
            Shumate.MapSource source = registry.get_by_id (Shumate.MAP_SOURCE_OSM_MAPNIK);
            assert_nonnull (source);
            simple_map.map_source = source;

            portal.location_updated.connect (on_location_updated);
        }

        [GtkCallback]
        private void on_start_button_clicked () {
            Xdp.LocationAccuracy accuracy = NONE;
            var model = accuracy_row.model as Gtk.StringList;
            var selected = model.get_string (accuracy_row.selected);

            switch (selected) {
                case "None":
                    accuracy = NONE;
                    break;

                case "Exact":
                    accuracy = EXACT;
                    break;

                case "Street":
                    accuracy = STREET;
                    break;

                case "Neighborhood":
                    accuracy = NEIGHBORHOOD;
                    break;

                case "City":
                    accuracy = CITY;
                    break;

                case "Country":
                    accuracy = COUNTRY;
                    break;

                default:
                    warning ("Unexpected output while getting accuracy. Defaulting to none");
                    break;
            }

            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
            portal.location_monitor_start.begin (
                parent,
                (uint) distance_entry.value,
                (uint) time_entry.value,
                accuracy,
                NONE,
                null,
                callback
            );
        }

        private void on_location_updated (
            double latitude,
            double longitude,
            double altitude,
            double accuracy,
            double speed,
            double heading
        ) {
            map_location.center_on (latitude, longitude);
            map_location.go_to_full_with_duration (latitude, longitude, 300, 600);

            lat_label.label = latitude.to_string ();
            longi_label.label = longitude.to_string ();
            alti_label.label = altitude.to_string ();
            acc_label.label = accuracy.to_string ();
            speed_label.label = speed.to_string ();
            head_label.label = heading.to_string ();
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                bool result = portal.location_monitor_start.end (res);
                if (result) {
                    result_box.visible = true;
                    monitor_active = true;
                    error_label.visible = false;
                }

                else {
                    critical ("Unable to get location");
                    error_label.visible = true;
                    error_label.label = "Unable to get location";
                }
            }
            catch (Error e) {
                critical (e.message);
                error_label.label = e.message;
                error_label.visible = true;
            }
        }

        [GtkCallback]
        private void on_stop_button_clicked () {
            portal.location_monitor_stop ();
            monitor_active = false;
        }
    }
}
