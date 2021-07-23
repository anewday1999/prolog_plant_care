from pyswip import Prolog, Query
import pyswip, ctypes

class PrologMT(pyswip.Prolog):
    """Multi-threaded (one-to-one) pyswip.Prolog ad-hoc reimpl"""
    _swipl = pyswip.core._lib

    PL_thread_self = _swipl.PL_thread_self
    PL_thread_self.restype = ctypes.c_int

    PL_thread_attach_engine = _swipl.PL_thread_attach_engine
    PL_thread_attach_engine.argtypes = [ctypes.c_void_p]
    PL_thread_attach_engine.restype = ctypes.c_int

    @classmethod
    def _init_prolog_thread(cls):
        pengine_id = cls.PL_thread_self()
        if (pengine_id == -1):
            pengine_id = cls.PL_thread_attach_engine(None)
            print("{INFO} attach pengine to thread: %d" % pengine_id)
        if (pengine_id == -1):
            raise pyswip.prolog.PrologError("Unable to attach new Prolog engine to the thread")
        elif (pengine_id == -2):
            print("{WARN} Single-threaded swipl build, beware!")

    class _QueryWrapper(pyswip.Prolog._QueryWrapper):
        def __call__(self, *args, **kwargs):
            PrologMT._init_prolog_thread()
            return super().__call__(*args, **kwargs)

prolog = PrologMT()
prolog.consult("./main.pl")
#insertPlant(Id, Name, TypeName, IsGrown, IsOutside) 
#plant(integer Id, Name, TypeName, integer IsGrown, real CurrentWS, integer CurrentHoursUnderSunshine, integer IsOutside).
list(prolog.query("insertPlant(1, 'MyPlant', 'Ageratum', 0, 0).")) # them 2 cay
list(prolog.query("insertPlant(2, 'MyPlant', 'Ageratum', 0, 0)."))

list(prolog.query("updatePlantsFile."))

list(prolog.query("insertPlant(3, 'MyPlant', 'Ageratum', 0, 0)."))

list(prolog.query("updatePlantsFile."))

list(prolog.query("deletePlant(1)."))

list(prolog.query("updatePlantsFile."))

list(prolog.query("deletePlant(2)."))

list(prolog.query("updatePlantsFile."))

for res in prolog.query("plant(X1, X2, X3, X4, X5, X6, X7)."):
    print("After inserting", res['X5'])

list(prolog.query("update."))

for res in prolog.query("plant(X1, X2, X3, X4, X5, X6, X7)."):
    print(f"Water storage : {res['X5']} , IsOutside : {res['X7']}")
    
 
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))
list(prolog.query("update."))


for res in prolog.query("plant(X1, X2, X3, X4, X5, X6, X7)."):
    print(f"Water storage : {res['X5']} , HoursUnderSun : {res['X6']},  IsOutside : {res['X7']}")


for res in prolog.query("needsWater(Id)"):
    print("Needs Water",res['Id'])

for res in prolog.query("needsLight(Id)"):
    print("Needs Light",res['Id'])

for res in prolog.query("needsToBeInside(Id)"):
    print("Needs To Be Inside",res['Id'])

list(prolog.query("watering(1)."))
list(prolog.query("puttingOutside(1)."))

for res in prolog.query("plant(X1, X2, X3, X4, X5, X6, X7)."):
    print(f"Water storage : {res['X5']} , IsOutside : {res['X7']}")

