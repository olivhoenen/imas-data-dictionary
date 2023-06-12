Units
=====

The Data Dictionary specifies units for floating point and complex data nodes.
On the reference pages, units are indicated between square brackets.


Dimensionless units
'''''''''''''''''''

Dimensionless quantities have ``-`` indicated as their unit.


Use case dependent units
''''''''''''''''''''''''

Some quantities have use case dependent units, for example
:dd:node:`controllers/linear_controller/pid/p`. The units for these quantities are
indicated as ``mixed``.


``as_parent`` units
'''''''''''''''''''

.. todo:: check if we can resolve these during generation

The Data Dictionary can also indicate that a quantity has the same units as
their parent structure, for example
:dd:node:`core_profiles/profiles_1d/ion/velocity/radial`. Those units are
indicated as ``as_parent`` and you can check the parent structure for their
units (:math:`\mathrm{m}\cdot\mathrm{s}^{-1}` in this example).
