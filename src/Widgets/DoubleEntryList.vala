/* DoubleEntryList.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class DoubleEntryList : EntryList {
        public string start_placeholder { get; set construct; default = ""; }
        public string end_placeholder { get; set construct; default = ""; }

        protected override void add_new_row () {
            var n_row = new DoubleEntryRow () {
                middle_widget = new Gtk.Label ("="),
                start_placeholder = this.start_placeholder,
                end_placeholder = this.end_placeholder
            };
            listbox.remove (new_address_row);
            listbox.append (n_row);
            listbox.append (new_address_row);
        }

        public override string[] retrieve_strings () {
            string[] strings = {};
            int i = 0;

            Gtk.ListBoxRow? current_row;
            current_row = listbox.get_row_at_index (i);

            while ((current_row != null) || (current_row != new_address_row)) {
                var row = (DoubleEntryRow) current_row;

                if (row.start_text == "" || row.end_text == "") {
                    warning ("In row %i one of the fields is empty", i);
                    continue;
                }

                strings += "%s=%s".printf (row.start_text, row.end_text);
                i++;
                current_row = listbox.get_row_at_index (i);
            }
            return strings;
        }
    }

    internal class DoubleEntryRow : Adw.PreferencesRow {
        private Gtk.CenterBox center_box = new Gtk.CenterBox ();
        private Gtk.Entry start_entry = new Gtk.Entry () {
            margin_start = 6,
            margin_top = 6,
            margin_bottom = 6
        };
        private Gtk.Entry end_entry = new Gtk.Entry () {
            hexpand = true,
            halign = END,
            margin_end = 6,
            margin_top = 6,
            margin_bottom = 6
        };

        public string start_text {
            get {
                return start_entry.text;
            }
        }

        public string start_placeholder {
            get {
                return start_entry.placeholder_text;
            }
            set {
                start_entry.placeholder_text = value;
            }
        }

        public string end_placeholder {
            get {
                return end_entry.placeholder_text;
            }
            set {
                end_entry.placeholder_text = value;
            }
        }

        public string end_text {
            get {
                return end_entry.text;
            }
        }

        public Gtk.Widget middle_widget {
            get {
                return center_box.get_center_widget ();
            }
            set {
                center_box.set_center_widget (value);
            }
        }
        construct {
            child = center_box;
            middle_widget = new Gtk.Label ("=");
            center_box.set_orientation (HORIZONTAL);
            center_box.set_start_widget (start_entry);
            center_box.set_end_widget (end_entry);
        }
    }
}
