/* Location.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Location : Page {
        private Shumate.Map map_location;
        private Gtk.SpinButton distance_entry;
        private Gtk.SpinButton time_entry;
        private Adw.ComboRow accuracy_row;

        private Gtk.Button start_button;
        private Gtk.Button stop_button;

        private Gtk.Box result_box;
        private Gtk.Label lat_label;
        private Gtk.Label longi_label;
        private Gtk.Label alti_label;
        private Gtk.Label acc_label;
        private Gtk.Label speed_label;
        private Gtk.Label head_label;

        private Gtk.Label error_label;

        public bool monitor_active { get; private set; }

        public Location (Xdp.Portal portal_) {
            Object (
                portal: portal_,
                title: "Location"
            );
        }

        construct {
            build_ui ();
            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );

            bind_property ("monitor-active",
                start_button, "sensitive",
                SYNC_CREATE | INVERT_BOOLEAN
            );

            bind_property ("monitor-active",
                stop_button, "sensitive",
                SYNC_CREATE
            );

            start_button.clicked.connect (on_start_button_clicked);
            stop_button.clicked.connect (on_stop_button_clicked);
            portal.location_updated.connect (on_location_updated);
        }

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
            map_location.center_on (longitude, altitude);

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

        private void on_stop_button_clicked () {
            portal.location_monitor_stop ();
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Location.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                distance_entry = builder.get_object ("distance_entry") as Gtk.SpinButton;
                time_entry = builder.get_object ("time_entry") as Gtk.SpinButton;
                accuracy_row = builder.get_object ("accuracy_row") as Adw.ComboRow;

                start_button = builder.get_object ("start_button") as Gtk.Button;
                stop_button = builder.get_object ("stop_button") as Gtk.Button;

                result_box = builder.get_object ("result_box") as Gtk.Box;
                lat_label = builder.get_object ("lat_label") as Gtk.Label;
                longi_label = builder.get_object ("longi_label") as Gtk.Label;
                alti_label = builder.get_object ("alti_label") as Gtk.Label;
                acc_label = builder.get_object ("acc_label") as Gtk.Label;
                speed_label = builder.get_object ("speed_label") as Gtk.Label;
                head_label = builder.get_object ("head_label") as Gtk.Label;

                error_label = builder.get_object ("error_label") as Gtk.Label;

                map_location = new Shumate.Map () {
                    height_request = 300
                };

                var registry = new Shumate.MapSourceRegistry.with_defaults ();
                var source = registry.get_by_id (Shumate.MAP_SOURCE_OSM_MAPNIK);

                var view_port = map_location.viewport;
                var layer = new Shumate.MapLayer (source, view_port);
                map_location.add_layer (layer);

                map_location.set_map_source (source);
                view_port.reference_map_source = source;
                view_port.zoom_level = 6;

                var license = new Shumate.License ();
                license.map = map_location;
                result_box.prepend (license);
                result_box.prepend (map_location);
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
