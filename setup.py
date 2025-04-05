from setuptools import setup, find_packages

setup(
    name='scales',
    version='0.1.0',
    packages=find_packages(where='python'),
    package_dir={'': 'python'},
    entry_points={
        'console_scripts': [
            'scales=scales:main',
        ],
    },
    install_requires=[
        'pytest',
    ],
    extras_require={
        'dev': ['pytest']
    }
)