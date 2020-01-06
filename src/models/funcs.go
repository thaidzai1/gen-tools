package models

// CountFilterQueryParams ...
func (fl ModelDefination) CountFilterQueryParams() int {
	for _, fd := range fl.Filters {
		if fd.Name == "q" {
			return len(fd.Fields)
		}
	}
	return 0
}
