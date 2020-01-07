package models

// CountFilterQueryParams ...
func (model *ModelDefination) CountFilterQueryParams() int {
	for _, fd := range model.Filters {
		if fd.Name == "q" {
			return len(fd.Fields)
		}
	}
	return 0
}

// Inc ...
func (model *ModelDefination) Inc(i int) int {
	return i + 1
}
