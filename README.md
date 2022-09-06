
# IMAS Data Dictionary

The Data Dictionary is the implementation of the Data Model of ITER's Integrated Modelling & Analysis Suite (IMAS). It describes the structuring and naming of data (as a set of Interface Data Structures or IDS) being used for both simulated and experimental data in a machine agnostic manner.

IDSs are used for standardizing data exploration and comparison as well as a coupling interface between codes in an Integrated Modelling workflow. The Data Dictionary itself does not describes explicitely how the data will be stored on disk, but is being used at compile time or at runtime by various data access software (e.g. the [Access-Layer](https://git.iter.org/projects/IMAS/repos/access-layer) which will handle data archiving and retrieving in applications.

IDSs of the Data Dictionary follow a strict lifecycle that aims at controlling the compatibility between various releases. This lifecycle is fully described in the following external document: [ITER_D_QQYMUK](https://user.iter.org/?uid=QQYMUK).

As it is generic and machine agnostic by design, the IMAS Data Model and by extension its implementation as the Data Dictionary have the potential to serve as a data standard for the fusion community. As such, it will benefit from a wide involvement of specialists and active users and developers in the various areas being described. If you want to contribute to the improvement of the Data Dictionary, either as a developer, a specific system/area specilist or an occasional user providing feedback, please look at [CONTRIBUTING.md](CONTRIBUTING.md).


