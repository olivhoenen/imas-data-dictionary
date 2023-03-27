
# IMAS Data Dictionary

The Data Dictionary is the implementation of the Data Model of ITER's Integrated Modelling & Analysis Suite (IMAS). It describes the structuring and naming of data (as a set of Interface Data Structures or IDSs) being used for both simulated and experimental data in a machine agnostic manner.

IDSs are used for standardizing data representation, facilitating exploration and comparison, as well as for standardizing coupling interfaces between codes in an Integrated Modelling workflow. The Data Dictionary itself does not describe explicitly how the data will be stored on disk but is used at compile time or at runtime by various pieces of data access software (e.g. the [Access-Layer](https://git.iter.org/projects/IMAS/repos/access-layer) which handle data archiving and retrieval within applications.

IDSs of the Data Dictionary follow a strict lifecycle that aims at controlling the compatibility between various releases. This lifecycle is fully described in the following external document: [ITER_D_QQYMUK](https://user.iter.org/?uid=QQYMUK).

As it is generic and machine agnostic by design, the IMAS Data Model, and by extension its implementation as the Data Dictionary, have the potential to serve as a data standard for the fusion community. As such, it benefits from the wide involvement of specialists and active users and developers in the various areas being described. If you want to contribute to the improvement of the Data Dictionary, either as a developer, a specific system/area specilist or an occasional user providing feedback, please look at [CONTRIBUTING.md](CONTRIBUTING.md).


# Python installation
Data dictionary can be installed using python pip install. Following is the process for the same.
Generate idsdef.xml once files are checked out


```sh
module load Python/3.8.6-GCCcore-10.2.0
module load Saxon-HE/11.4-Java-11

git clone ssh://git@git.iter.org/imas/data-dictionary.git
cd data_dictionary
pip install . [--user]

# if installing with other ways
# 1> if installing with traditional setuptools method
python install gitpython 
python setup.py install

# 2> if building using python -m build
export PROJECT_PATH=`pwd` 
python -m build

# Clean all files
python clean.py

# Testing
python test.py
```