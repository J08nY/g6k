#cython: linetrace=True
"""
Sieving parameters.
"""

from contextlib import contextmanager

@contextmanager
def temp_params(self, **kwds):
    """
    Temporarily change the sieving parameters.

    EXAMPLE::

        >>> from fpylll import IntegerMatrix, GSO
        >>> from g6k import Siever
        >>> A = IntegerMatrix.random(50, "qary", k=25, bits=10)
        >>> g6k = Siever(A, seed=0x1337)
        >>> with g6k.temp_params(reserved_n=20):
        ...      print(g6k.params.reserved_n)
        20

        >>> g6k.params.reserved_n
        0

    """
    old_params = self.params
    new_params = self.params.new(**kwds)
    self.params = new_params
    yield
    self.params = old_params


cdef class SieverParams(object):
    """
    Parameters for sieving.
    """

    known_attributes = [
        # C++
        "reserved_n",
        "reserved_db_size",
        "threads",
        "lift_left_bound",
        "sample_by_sums",
        "otf_lift",
        "lift_radius",
        "lift_unitary_only",
        "saturation_ratio",
        "saturation_radius",
        "triplesieve_saturation_radius",
        "bgj1_improvement_db_ratio",
        "bgj1_resort_ratio",
        "bgj1_transaction_bulk_size",
        "simhash_codes_basedir",
        # Python
        "db_size_base",
        "db_size_factor",
        "bgj1_bucket_size_expo",
        "bgj1_bucket_size_factor",
        "triplesieve_db_size_base",
        "triplesieve_db_size_factor",
        "default_sieve",
        "gauss_crossover"
    ]

    def __init__(self, **kwds):
        """
        EXAMPLE::

            >>> from g6k import SieverParams
            >>> SieverParams()
            SieverParams({})

            >>> SieverParams(otf_lift=False)
            SieverParams({'otf_lift': False})

        Note that this class will accept anything, to support arbitrary additional parameters::

            >>> SieverParams(uh_oh_some_clever_new_feature=False)
            SieverParams({'uh_oh_some_clever_new_feature': False})

        """

        # We keep a list of all possible attributes to produce dicts etc.

        self._read_only = 0
        self._pyattr = {}

        if "db_size_base" not in kwds:
            kwds["db_size_base"] = (4./3.)**.5     # The initial db_size for sieving is
        if "db_size_factor" not in kwds:
            kwds["db_size_factor"] =  3.2          # db_size_factor * db_size_base**n
        if "bgj1_bucket_size_expo" not in kwds:
            kwds["bgj1_bucket_size_expo"] = .5     # The initial bgj1_bucket_size for sieving is
        if "bgj1_bucket_size_factor" not in kwds:
            kwds["bgj1_bucket_size_factor"] =  3.2

        # TODO : remove the two following ?
        if "triplesieve_db_size_base" not in kwds:
            kwds["triplesieve_db_size_base"] = (1.2999)**.5 # The initial db_size for triple sieve
                                                            # (sqrt(3) * 3/4)
        if "triplesieve_db_size_factor" not in kwds:
            kwds["triplesieve_db_size_factor"] = 2.5       # db_size_factor_3sieve *
                                                           # db_size_base_3sieve**n for the next
                                                           # iteration

        if "reserved_db_size" not in kwds and "reserved_n" in kwds:
            kwds["reserved_db_size"] = kwds["db_size_factor"] * kwds["db_size_base"]**kwds["reserved_n"] + 100

        if "default_sieve" not in kwds or kwds["default_sieve"] is None:
            kwds["default_sieve"] = "gauss_triple_mt"
        if "gauss_crossover" not in kwds:
            kwds["gauss_crossover"] = 50

        read_only = False
        if "read_only" in kwds:
            read_only = True
            del kwds["read_only"]

        for k, v in kwds.items():
            self._set(k, v)

        if read_only:
            self.set_read_only()

    cpdef _set(self, str key, object value):
        if self._read_only:
            raise ValueError("This object is read only, create a copy to edit.")

        if key == "reserved_n":
            self._core.reserved_n = value
        elif key == "reserved_db_size":
            self._core.reserved_db_size = value
        elif key == "threads":
            self._core.threads = value
        elif key == "lift_left_bound":
            self._core.lift_left_bound = value
        elif key == "sample_by_sums":
            self._core.sample_by_sums = value
        elif key == "otf_lift":
            self._core.otf_lift = value
        elif key == "lift_radius":
            self._core.lift_radius = value
        elif key == "lift_unitary_only":
            self._core.lift_unitary_only = value
        elif key == "saturation_ratio":
            self._core.saturation_ratio = value
        elif key == "saturation_radius":
            self._core.saturation_radius = value
        elif key == "triplesieve_saturation_radius":
            self._core.triplesieve_saturation_radius = value
        elif key == "bgj1_improvement_db_ratio":
            self._core.bgj1_improvement_db_ratio = value
        elif key == "bgj1_resort_ratio":
            self._core.bgj1_resort_ratio = value
        elif key == "bgj1_transaction_bulk_size":
            self._core.bgj1_transaction_bulk_size = value
        elif key == "simhash_codes_basedir":
            self._core.simhash_codes_basedir = value
        else:
            self._pyattr[key] = value

    cpdef _get(self, str key):
        if key == "reserved_n":
            return self._core.reserved_n
        elif key == "reserved_db_size":
            return self._core.reserved_db_size
        elif key == "threads":
            return self._core.threads
        elif key == "lift_left_bound":
            return self._core.lift_left_bound
        elif key == "sample_by_sums":
            return self._core.sample_by_sums
        elif key == "otf_lift":
            return self._core.otf_lift
        elif key == "lift_radius":
            return self._core.lift_radius
        elif key == "lift_unitary_only":
            return self._core.lift_unitary_only
        elif key == "saturation_ratio":
            return self._core.saturation_ratio
        elif key == "saturation_radius":
            return self._core.saturation_radius
        elif key == "triplesieve_saturation_radius":
            return self._core.triplesieve_saturation_radius
        elif key == "bgj1_improvement_db_ratio":
            return self._core.bgj1_improvement_db_ratio
        elif key == "bgj1_resort_ratio":
            return self._core.bgj1_resort_ratio
        elif key == "bgj1_transaction_bulk_size":
            return self._core.bgj1_transaction_bulk_size
        elif key == "simhash_codes_basedir":
            return self._core.simhash_codes_basedir
        else:
            return self._pyattr[key]

    def get(self, k, d=None):
        """
        D.get(k[,d]) -> D[k] if k in D, else d. d defaults to None::

            >>> from g6k import SieverParams
            >>> SieverParams().get("foo", 1)
            1
            >>> SieverParams(foo=2).get("foo", 1)
            2

        """
        try:
            return self._get(k)
        except KeyError:
            return d

    def pop(self, k, d=None):
        """
        Like get but also remove element if it exists and is a Python attribute::

            >>> from g6k import SieverParams
            >>> SieverParams().pop("foo", 1)
            1
            >>> sp =SieverParams(foo=2); sp.pop("foo", 1)
            2
            >>> sp.pop("foo", 1)
            1

        """
        try:
            r = self._get(k)
            del self[k]
            return r
        except KeyError:
            return d

    def __getattr__(self, key):
        """
        Attribute read access::

            >>> from g6k import SieverParams
            >>> sp = SieverParams()
            >>> sp.bgj1_bucket_size_factor
            3.2

            >>> sp.bgj2_bucket_max_size_factor
            Traceback (most recent call last):
            ...
            AttributeError: 'SieverParams' object has no attribute 'bgj2_bucket_max_size_factor'

        """
        try:
            return self._get(key)
        except KeyError:
            raise AttributeError("'SieverParams' object has no attribute '%s'"%key)

    def __setattr__(self, key, value):
        """
        Attribute write access::

            >>> from g6k import SieverParams
            >>> sp = SieverParams()
            >>> sp.bgj2_bucket_max_size_factor
            Traceback (most recent call last):
            ...
            AttributeError: 'SieverParams' object has no attribute 'bgj2_bucket_max_size_factor'

            >>> sp.bgj2_bucket_max_size_factor = 2.0
            >>> sp.bgj2_bucket_max_size_factor
            2.0

        """
        self._set(key, value)

    def __getitem__(self, key):
        """
        Dictionary-style read access::

            >>> from g6k import SieverParams
            >>> sp = SieverParams()
            >>> sp["bgj1_bucket_size_factor"]
            3.2

            >>> sp["bgj2_bucket_max_size_factor"]
            Traceback (most recent call last):
            ...
            KeyError: 'bgj2_bucket_max_size_factor'

        """
        return self._get(key)

    def __setitem__(self, key, value):
        """
        Dictionary-style write access::

            >>> from g6k import SieverParams
            >>> sp = SieverParams()
            >>> sp["bgj2_bucket_max_size_factor"]
            Traceback (most recent call last):
            ...
            KeyError: 'bgj2_bucket_max_size_factor'

            >>> sp["bgj2_bucket_max_size_factor"] = 2.0
            >>> sp["bgj2_bucket_max_size_factor"]
            2.0

        """
        self._set(key, value)

    def __delitem__(self, key):
        """
        Dictionary-style deletion::

            >>> from g6k import SieverParams
            >>> sp = SieverParams()
            >>> del sp["bgj2_bucket_max_size_factor"]
            Traceback (most recent call last):
            ...
            KeyError: 'bgj2_bucket_max_size_factor'

            >>> sp["bgj2_bucket_max_size_factor"] = 2.0
            >>> del sp["bgj2_bucket_max_size_factor"]

            >>> sp["bgj1_improvement_db_ratio"]
            0.65
            >>> del sp["bgj1_improvement_db_ratio"]
            Traceback (most recent call last):
            ...
            KeyError: 'bgj1_improvement_db_ratio'

            >>> sp["bgj1_improvement_db_ratio"]
            0.65

        """
        del self._pyattr[key]


    def dict(self, minimal=False):
        """
        Return a dictionary for all attributes of this params object.

        :param minimal: If ``True`` only return those attributes that do not match the default
            value.

        EXAMPLE::

            >>> from g6k import SieverParams
            >>> sp = SieverParams(otf_lift=False)
            >>> sp.dict() # doctest: +ELLIPSIS
            {'triplesieve_db_size_base': 1.1401315713548152, ... 'sample_by_sums': True}

            >>> sp.dict(True)
            {'otf_lift': False}

        """
        d = {}
        if not minimal:
            for k in self.known_attributes:
                d[k] = self._get(k)
            for k, v in self._pyattr.items():
                d[k] = v
        else:
            t = self.__class__()
            for k in self.known_attributes:
                if k not in t or self._get(k) != t[k]:
                    d[k] = self._get(k)
            for k, v in self._pyattr.items():
                if k not in t or self._get(k) != t[k]:
                    d[k] = v
        return d

    def items(self):
        yield from self.iteritems()

    def iteritems(self):
        """
        Iterate over key, value pairs::

            >>> from g6k import SieverParams
            >>> sp = SieverParams(otf_lift=False)
            >>> _ = [(k, v) for k, v in sp.items()]

        """
        for k in self.known_attributes:
            yield k, self._get(k)
        for k, v in self._pyattr.items():
            if k not in self.known_attributes:
                yield k, v

    def __iter__(self):
        """
        Iterate over keys::

            >>> from g6k import SieverParams
            >>> sp = SieverParams(otf_lift=False)
            >>> _ = [k for k in sp]

        """
        for k in self.known_attributes:
            yield k
        for k, _ in self._pyattr.items():
            if k not in self.known_attributes:
                yield k

    def new(self,  **kwds):
        """
        Construct a new params object with attributes updated as given by provided ``kwds``::

            >>> from g6k import SieverParams
            >>> sp = SieverParams(); sp
            SieverParams({})
            >>> sp = sp.new(otf_lift=False); sp
            SieverParams({'otf_lift': False})

            >>> sp = sp.new(foo=2); sp
            SieverParams({'foo': 2, 'otf_lift': False})

        """
        d = self.dict(minimal=True)
        d.update(kwds)
        return self.__class__(**d)

    def __dir__(self):
        """
        EXAMPLE::

            >>> from g6k import SieverParams
            >>> dir(SieverParams())  # doctest: +ELLIPSIS
            ['__copy__', ... 'unknown_attributes']

        """

        l = self.known_attributes
        for k in list(self._pyattr.keys()):
            if k not in l:
                l.append(k)

        return list(self.__class__.__dict__.keys()) + l

    def __copy__(self):
        """
        EXAMPLE::

            >>> from copy import copy
            >>> from g6k import SieverParams
            >>> copy(SieverParams())
            SieverParams({})

        """
        return self.__class__(**self.dict(True))

    def __repr__(self):
        """
        EXAMPLE::

            >>> from g6k import SieverParams
            >>> SieverParams()
            SieverParams({})

        """
        return "%s(%s)"%(self.__class__.__name__,self.dict(minimal=True))

    def __reduce__(self):
        """
        EXAMPLE::

            >>> from pickle import dumps, loads
            >>> from g6k import SieverParams
            >>> loads(dumps(SieverParams()))
            SieverParams({})

        """
        return (unpickle_params, (self.__class__,) + tuple(self.dict().items()))

    @property
    def read_only(self):
        return self._read_only

    def set_read_only(self):
        self._read_only = True

    @property
    def unknown_attributes(self):
        """
        Return Python attributes not known in known_attributes.
        """
        t = []
        for k in self._pyattr:
            if k not in self.known_attributes:
                t.append(k)
        return tuple(t)

    def __hash__(self):
        return hash(tuple(self.items()))

    def __eq__(self, SieverParams other):
        return tuple(self.items()) == tuple(self.items())

def unpickle_params(cls, *d):
    return cls(**dict(d))
