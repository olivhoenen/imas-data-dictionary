.. _`coordinates`:

Coordinates and time handling
=============================

Dimensional quanitities such as :dd:data_type:`struct_array` and multi-dimensional
:ref:`data <data types>` nodes have associated coordinates. Coordinates can
refer to other data quantities in the IDS, which is indicated with the path to
the coordinate quantity. Alternatively, a coordinate can be a plain index, which
is indicated as ``1...N`` when the size of the coordinate is variable or -- for
example -- ``1...3`` when there is a strict number of items -- 3 in this case.

Note that time coordinates are special due to the time slice functionality
of the Access Layer. See the following section for more details.


Time coordinates and time handling
''''''''''''''''''''''''''''''''''

Some quantities (and array of structures) are time dependent.

.. todo:: static/dynamic/constant

This time-dependent coordinate is treated specially in the access layer, and it
depends on the value of ``ids_properties/homogeneous_time``. There are three
valid values for this property:

- ``0`` (heterogeneous time mode): time-dependent quantities in the IDS may have
  different time coordinates. The time coordinates are stored as indicated by
  the path in the documentation.
- ``1`` (homogeneous time mode): All time-dependent quantities in this IDS use
  the same time coordinate. This time coordinate is located in the root of the
  IDS, for example :dd:node:`core_profiles/time`. The time paths indicated in
  the documentation are unused in this case.
- ``2`` (time independent mode): The IDS stores no time-dependent data.

.. note::

    The Access Layer provides named constants for the allowed values:
    ``IDS_TIME_MODE_HETEROGENEOUS``, ``IDS_TIME_MODE_HOMOGENEOUS`` and
    ``IDS_TIME_MODE_INDEPENDENT``. See the Access Layer documentation for more
    details.

    .. todo:: link to AL docs
    
    Using these constants is preferred over the raw value: when reading code it
    is easier to understand :code:`ids.ids_properties.homogeneous_time =
    IDS_TIME_MODE_HOMOGENEOUS` then :code:`ids.ids_properties.homogeneous_time =
    1`.
