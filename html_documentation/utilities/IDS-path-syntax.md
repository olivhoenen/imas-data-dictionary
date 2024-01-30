# The IDS *path* syntax to identify a part of an IDS
​
## Scope
​
This document describes the syntax of the ***path*** that identifies a *part* of an IDS.
In this context a part can be defined by a given node (or node element in the case of an array of structure) 
with all its leaves, or by a single leaf of the IDS structure. As a reminder, nodes are structures or arrays 
of structure and leaves are quantities. 
​
Parts that are represented by arrays (either arrays of structure or quantities) can be identified
as a whole (all the elements of the array), as a range (contiguous elements within two bounds) or 
as a single element.

While this document presents of few examples of *URI fragments* where an *idspath* can be specified,
please refer to the [IMAS URI scheme](IMAS-URI-scheme.md) document for the full description of the URI syntax.
​
​
## Syntax
​
An IDS *path* is represented by a string that respects the following rules:
​
- a slash **`/`** separates nested structures, the leading one indicates the root of an IDS
- quantities (scalar or arrays) as well as structures and arrays of structures are given by their name
- for arrays (quantities and arrays of structure) all elements are covered unless an optional **range specifier** is given between round brackets **`()`** just after the array name
have their names followed by round brackets **`()`**, this is mandatory unless this array is in last position in the path
- several types of range specifiers are foreseen, e.g in 1D:
	+ `(:)` indicates all elements of the array (this is equivalent to not specifying a range)
	+ `(i)` indicates the i-th element of the array, 1 being the first element (same as Fortran arrays)
	+ `(i:j)` indicates all elements from the i-th to the j-th (both included)
- for nD arrays, a list of n range specifiers separated by commas must be given, e.g in 3D
	+ `(:,:,1)` represents a 2D slab for the first element in the last dimension (usually the time, unless the quantity is not time dependent or has one time dependent array of structure as ancestor)
​
​
## Use cases and examples
​
An IDS *path* can be used in the following cases: 

- alone, it can be used as a value of some fields (string) in IDSs or as an argument of a `partial_get` operation from a data-access library;
- as part of a URI fragment to identify a specific subset of a given IDS in a given data-entry.
​
### *idspath* or *fragment* as `path` field in IDSs

In several places in the Data-Dictionary, specific string fields of an IDS allow references to be made to other fields in the same IDS. 
This is the case for instance of the field `/ids_properties/provenance/node(:)/path`. In this field, an idspath is expected to point 
to a subset of the current IDS.

In other cases, the reference `path` field allows to point to a different IDS within the same data-entry (e.g in `grid_ggd(:)/path`). 
In such a case, the string following the syntax of idspath can point to a subset of the same IDS, or a subset of another IDS.
In the latter case, `path` can contain a *same-document* URI fragment (i.e. following the syntax `#ids[:occurrence][/idspath]`). 
Refer to [URI syntax](IMAS-URI-scheme.md) documentation for more information.

### *idspath* in URI fragment

When *idspath* is given as a part of an IMAS URI, it is always contains the specific IDS (and optionally its occurrence) 
and follows the syntax `#ids[:occurrence][/idspath]` described in the [URI syntax](IMAS-URI-scheme.md) documentation. 

### *idspath* as an argument of a `partial_get` operation
​
When given as an argument of the `partial_get` function of the Access-Layer, please refer to the [Access-Layer User Guide](https://user.iter.org/?uid=YSQENW&action=get_document) 
to get more information about possible limitations of the supported languages and allowed comintations of range specifiers.
​
​
