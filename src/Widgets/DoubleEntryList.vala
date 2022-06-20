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
                middle_char = "=",
                start_placeholder = this.start_placeholder,
                end_placeholder = this.end_placeholder
            };
            listbox.remove (new_address_row);
            listbox.append (n_row);
            listbox.append (new_address_row);
        }

        public override string[] retrieve_strings () {
            string[] strings = {};
            int i = -1;

            Gtk.ListBoxRow? current_row = null;

            do {
                i++;
                current_row = listbox.get_row_at_index (i);

                if (current_row == new_address_row)
                    break;

                var row = (DoubleEntryRow) current_row;

                if (row.start_text == "" || row.end_text == "") {
                    warning ("In row %i one of the fields is empty", i);
                    continue;
                }

                strings += "%s%s%s".printf (row.start_text, row.middle_char, row.end_text);
            } while ((current_row != null));
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
        private Gtk.Label middle_char_label = new Gtk.Label ("");

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

        public string middle_char {
            get {
                return middle_char_label.label;
            }
            set {
                middle_char_label.label = value;
            }
        }

        construct {
            child = center_box;
            center_box.set_center_widget (middle_char_label);
            center_box.set_orientation (HORIZONTAL);
            center_box.set_start_widget (start_entry);
            center_box.set_end_widget (end_entry);
        }
    }
}
