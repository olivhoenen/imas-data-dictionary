.. test
.. ----

.. - .. details:: :dd:node:`~core_profiles/ids_properties`

..     - :dd:node:`~core_profiles/ids_properties/comment`
..     - :dd:node:`~core_profiles/ids_properties/homogeneous_time`
..     - :dd:node:`~core_profiles/ids_properties/source`
..     - :dd:node:`~core_profiles/ids_properties/provider`
..     - :dd:node:`~core_profiles/ids_properties/creation_date`
..     - .. details:: :dd:node:`~core_profiles/ids_properties/version_put`

..         - :dd:node:`~core_profiles/ids_properties/version_put/data_dictionary`
..         - :dd:node:`~core_profiles/ids_properties/version_put/access_layer`
..         - :dd:node:`~core_profiles/ids_properties/version_put/access_layer_language`

..     - .. details:: :dd:node:`~core_profiles/ids_properties/provenance`

..         - .. details:: :dd:node:`~core_profiles/ids_properties/provenance/node`

..             - :dd:node:`~core_profiles/ids_properties/provenance/node/path`
..             - :dd:node:`~core_profiles/ids_properties/provenance/node/sources`

.. - :dd:node:`~core_profiles/profiles_1d`
.. - :dd:node:`~core_profiles/global_quantities`
.. - :dd:node:`~core_profiles/vacuum_toroidal_field`
.. - :dd:node:`~core_profiles/code`
.. - :dd:node:`~core_profiles/time`



.. Contents:

.. .. list-table::
..     :header-rows: 1
..     :class: test

..     - * Name
..       * Description
..     - * :ref:`ids_properties <core_profiles/ids_properties>`
..       * Interface Data Structure properties. This element identifies the node
..         above as an IDS
..     - * profiles_1d
..       * Core plasma radial profiles for various time slices
..     - * global_quantities
..       * Various global quantities derived from the profiles
..     - * vacuum_toroidal_field
..       * Characteristics of the vacuum toroidal field (used in rho_tor definition
..         and in the normalization of current densities)
..     - * code
..       * Generic decription of the code-specific parameters for the code that has
..         produced this IDS
..     - * time
..       * Generic time


.. Core profiles (overview)
.. ========================


.. - ids_properties

..   - comment
..   - homogeneous_time
..   - source
..   - provider
..   - creation_date
..   - version_put

..     - data_dictionary
..     - access_layer
..     - access_layer_language

..   - provenance

..     - node

..       - path
..       - sources

Core profiles reference (mock-up)
=================================

.. dd:ids:: core_profiles

  Core plasma radial profiles

  .. list-table::
    :header-rows: 1

    - * Property
      * Value
    - * Lifecycle status
      * `Active` since version 3.1.0
    - * Last change
      * Version 3.34.0
    - * `Maximum number of occurrences`
      * 15

  Test math display:

  .. math::

    \int_{-\infty}^{\infty} e^{-x^2} \mathrm{d}x = \sqrt \pi 

  Test inline math: :math:`\pi \approx 3.141`.

  .. dd:node:: ids_properties
    :data_type: struct

    Interface Data Structure properties. This element identifies the node above as an IDS

    .. dd:node:: ids_properties/comment
      :data_type: STR_0D
      :type: constant
      
      Any comment describing the content of this IDS

    .. dd:node:: ids_properties/homogeneous_time
      :data_type: INT_0D
      :type: constant

      This node must be filled (with 0, 1, or 2) for the IDS to be valid. If 1,
      the time of this IDS is homogeneous, i.e. the time values for this IDS are
      stored in the time node just below the root of this IDS. If 0, the time
      values are stored in the various time fields at lower levels in the tree.
      In the case only constant or static nodes are filled within the IDS,
      homogeneous_time must be set to 2.

    .. dd:node:: ids_properties/source
        :data_type: STR_0D

        Source of the data (any comment describing the origin of the data :
        code, path to diagnostic signals, processing method, ...). Superseeded
        by the new provenance structure.

        .. list-table::
            :header-rows: 1

            - * Property
              * Value
            - * Lifecycle status
              * `Obsolescent` since version 3.34.0

    .. dd:node:: ids_properties/provider
        :data_type: STR_0D

        Name of the person in charge of producing this data

    .. dd:node:: ids_properties/creation_date
        :data_type: STR_0D

        Date at which this data has been produced

    .. dd:node:: ids_properties/version_put
        :data_type: struct

        Version of the access layer package used to PUT this IDS

    .. dd:node:: ids_properties/provenance
      :data_type: struct

      :lifecycle status: `Alpha` since version 3.34.0

      Provenance information about this IDS.

      .. dd:node:: ids_properties/provenance/node(i1)
        :data_type: struct_array
        :type: constant

        
        .. list-table::
          :header-rows: 1

          - * Property
            * Value
          - * Coordinates
            * `1...N`

        Set of IDS nodes for which the provenance is given. The
        provenance information applies to the whole structure below the
        IDS node. For documenting provenance information for the whole
        IDS, set the size of this array of structure to 1 and leave the
        child "path" node empty

        .. dd:node:: ids_properties/provenance/node(i1)/path
          :data_type: STR_0D
          :type: constant

          Path of the node within the IDS, following the syntax given
          in the link below. If empty, means the provenance
          information applies to the whole IDS.

        .. dd:node:: ids_properties/provenance/node(i1)/sources
          :data_type: STR_1D
          :type: constant

          
          .. list-table::
            :header-rows: 1

            - * Property
              * Value
            - * Coordinates
              * `1...N`

          List of sources used to import or calculate this node,
          identified as explained below. In case the node is the
          result of of a calculation / data processing, the source is
          an input to the process described in the "code" structure at
          the root of the IDS. The source can be an IDS (identified by
          a URI or a persitent identifier, see syntax in the link
          below) or non-IDS data imported directly from an non-IMAS
          database (identified by the command used to import the
          source, or the persistent identifier of the data source).
          Often data are obtained by a chain of processes, however
          only the last process input are recorded here. The full
          chain of provenance has then to be reconstructed recursively
          from the provenance information contained in the data
          sources.

  .. dd:node:: profiles_1d(itime)
    :data_type: struct_array
    :type: dynamic

    :Coordinate: :dd:node:`profiles_1d(itime)/time`

    Core plasma radial profiles for various time slices

  .. dd:node:: global_quantities
    :data_type: struct

    Various global quantities derived from the profiles

  .. dd:node:: vacuum_toroidal_field
    :data_type: struct

    Characteristics of the vacuum toroidal field (used in rho_tor definition and
    in the normalization of current densities)

  .. dd:node:: code
    :data_type: struct

    Generic decription of the code-specific parameters for the code that has
    produced this IDS	

  .. dd:node:: time
    :data_type: FLT_1D
    :type: dynamic
    :unit: s

    :Coordinate: `1...N`

    Generic time
