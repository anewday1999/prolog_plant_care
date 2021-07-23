%timeStep :- 1 hour
%CSVWeather :- './Weather.csv'
%CSVPlantType :- './PlantTypes.csv'
%CSVPlant :- './Plants.csv'

%Temperature, Relative Humidity, Wind Speed, Rainfall Volumn
%weather(integer T, integer RH, integer V, integer P, integer DayOfYear, real Latitude, integer IsDayTime)
:- dynamic weather/7.

%Maximum Water Storage
%plantType(TypeName, real MaxWS, real Kp, integer Np, integer IsGrown).
:- dynamic plantType/5.

%plant(integer Id, Name, TypeName, integer IsGrown, real CurrentWS, integer CurrentHoursUnderSunshine, integer IsOutside).
:- dynamic plant/7.

%Read Data From CSV
import(FileName, Table) :- csv_read_file(FileName, Data, [functor(Table), separator(0',)]),maplist(assert, Data).

%Print plant data to file
exportPlants(FileName) :-
    findall(row(X1, X2, X3, X4, X5, X6, X7), plant(X1, X2, X3, X4, X5, X6, X7), Rows),
    csv_write_file(FileName, Rows, [separator(0',)]).

clearWeather :- retractall(weather(_, _, _, _, _, _, _)).
clearPlantTypes :- retractall(plantType(_, _, _, _, _)). 
clearPlants :- retractall(plant(_, _, _, _, _, _, _)).


:- clearPlantTypes,
	import('./PlantTypes.csv', 'plantType').

:- clearPlants,
	import('./Plants.csv', 'plant').

updateWeather
	:- clearWeather, 
	import('./Weather.csv', 'weather').

:- updateWeather.

insertPlant(Id, Name, TypeName, IsGrown, IsOutside) :-
	plantType(TypeName, MaxWS, _, _, IsGrown),
	assertz(plant(Id, Name, TypeName, IsGrown, MaxWS, 0, IsOutside)).

deletePlant(Id) :-
	retractall(plant(Id, _, _, _, _, _, _)).

e(X) :-
	weather(T, _, _, _, _, _, _),
	X is 0.6108*(e**((17.27*T)/(T+237.3))).
ea(X) :-
	weather(_, RH, _, _, _, _, _),
    e(E),
    X is E * RH / 100, !.
delta(X) :-
	weather(T, _, _, _, _, _, _),
    e(E),
    X is 4098*E/(T+237.3).

gamma(X) :- 
	X is 0.665*10**(-3).


eto(X) :-
	weather(T, _, V, _, _, _, _),
	g(G),
	rn(Rn),	
	delta(Delta),
	ea(Ea),
	e(E),	
	gamma(Gamma),
	X is (0.408*Delta*(Rn-G)/(Delta+Gamma*(1+0.34*V))+37*Gamma/(T+273)*V*(E-Ea)/(Delta+Gamma*(1+0.34*V))).



in(Id, X) :-
	weather(_, _, _, P, _, _, _),
	plant(Id, _, TypeName, IsGrown, _, _, IsOutside),
	plantType(TypeName, _, Kp, _, IsGrown),	
	eto(Eto),
	(IsOutside =:= 1 -> Ko is 1 ; Ko is 0.7),
	X is IsOutside*0.8*P+Ko*Kp*Eto.


rn(X) :- 
	weather(T, _, _, P, DayOfYear, Latitude, IsDayTime),
	Dr is 1+0.033*cos(2*pi/365*DayOfYear),
	Beta is 0.409*sin(2*pi/365*DayOfYear-1.39),
	Ws is acos(-tan(Latitude) * tan(Beta)),
	Ra is 24*60/pi*0.0820*Dr*(Ws*sin(Latitude)*sin(Beta)+cos(Latitude)*cos(Beta)*sin(Ws)),
	((P =\= 0, IsDayTime =:= 1) -> Kh is 1; Kh is 0),
	Rs is (0.25+0.5*Kh)*Ra,
	Rns is (1-0.17)*Rs,
	Rso is 0.75/Ra,
	ea(Ea),
	Rnl is 4.903*10**(-9)*T**4*(0.34-0.14*sqrt(Ea))*(1.35*Rs/Rso-0.35),
	X is Rns-Rnl.

g(X) :-

	weather(_, _, _, _, _, _, IsDayTime),
	rn(Rn),
	(IsDayTime =:= 1 -> X is 0.1*Rn; X is 0.5*Rn).

needsWater(Id) :-
	plant(Id, _, _, _, 0, _, _).


needsLight(Id) :-
	weather(_, _, _, _, _, _, 1),
	plant(Id, _, TypeName, IsGrown, _, CurrentHoursUnderSunshine, 0),
	plantType(TypeName, _, _, Np, IsGrown),
	CurrentHoursUnderSunshine < Np.

needsToBeInside(Id) :-
	weather(_, _, _, _, _, _, 1),
	plant(Id, _, TypeName, IsGrown, _, CurrentHoursUnderSunshine, 1),
	plantType(TypeName, _, _, Np, IsGrown),
	CurrentHoursUnderSunshine >= Np.


update :-
	updateWeather,
	weather(_, _, _, P, _, _, IsDayTime),
	plant(Id, Name, TypeName, IsGrown, CurrentWaterStorage, CurrentHoursUnderSunshine, IsOutside),
	in(Id, In),
	NewWS is max(0, CurrentWaterStorage - In),
	(IsDayTime =:= 0 -> NewHoursUnderSunShine is 0; ((P =:= 0, IsOutside =:=1) -> NewHoursUnderSunShine is CurrentHoursUnderSunshine + 1 ; NewHoursUnderSunShine is CurrentHoursUnderSunshine)),
	retractall(plant(Id, _, _, _, _, _, _)),
	asserta(plant(Id, Name, TypeName, IsGrown, NewWS, NewHoursUnderSunShine, IsOutside)).


watering(Id) :-
	plant(Id, Name, TypeName, IsGrown, 0, CurrentHoursUnderSunshine, IsOutside),
	plantType(TypeName, MaxWS, _, _, IsGrown),
	retract(plant(Id, _, _, _, _, _, _)),
	asserta(plant(Id, Name, TypeName, IsGrown, MaxWS, CurrentHoursUnderSunshine, IsOutside)).

puttingInside(Id) :-
	plant(Id, Name, TypeName, IsGrown, CurrentWS, CurrentHoursUnderSunshine, 1),
	retract(plant(Id, _, _, _, _, _, _)),
	asserta(plant(Id, Name, TypeName, IsGrown, CurrentWS, CurrentHoursUnderSunshine, 0)).

puttingOutside(Id) :-
	plant(Id, Name, TypeName, IsGrown, CurrentWS, CurrentHoursUnderSunshine, 0),
	retract(plant(Id, _, _, _, _, _, _)),
	asserta(plant(Id, Name, TypeName, IsGrown, CurrentWS, CurrentHoursUnderSunshine, 1)).

updatePlantsFile :- exportPlants('Plants.csv').