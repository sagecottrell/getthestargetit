class_name Zip

static func zip(one: Array, two: Array, strict=true) -> Array:
	if strict:
		assert(one.size() == two.size())
	var items = []
	for i in range(min(one.size(), two.size())):
		items.append([one[i], two[i]])
	return items
