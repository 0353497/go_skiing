# go_skiing

A new Flutter project.


## plan van aanpak:
 - maak eerst de homepagina en de settings pagina, want daar zit de minste logica in en is snel te doen
 - daarna ook de ranking pagina met alleen "No Ranking" later ga ik een ranking class maken en dan kan ik dat in de state managment zetten
 - daarna het ski spel, begin met de achtergrond en de bomen, maar niet te veel tijd aan besteden, want seamless animaties zijn pittig. 
 - daarna de slope met de gyroscope, denk dat dit wel goed gaat.
 - dan komt de skier met springen, wat redelijk goed te doen is.
 - daarna komt het lastigste de obstacles en de coins, dit word lastig omdat vanwege de spawn timer logica.
 - daarna kan ik de score toevoegen met de ranking als alles lukt,
 - als ik nog tijd over heb de screen recording maar denk niet dat dat gaat lukken.

 ## einde opdracht binnen tijd
### missende punten:
- geen screen recording
- geen boost op swipe down
- persistantly opgeslagen ranking niet, gebeurd alleen in de state management
- slope draait wel, maar is buggy. en de snelheid verandert niet.
- bomen zijn seamless, maar niet helemaal, is discutabel.
- ben ook vergeten om bij de reset de coins te setten naar 10. dit was gewoon een domme fout.
- ook heb ik de package name niet aangepast. omdat de vorige keer dat ik had gedaan kon ik er werkende apk meer van maken. dus heb ik besloten om dat bij de complete te checken en doen.


### waarom heb ik dit gemist:
screen recording is uitdagend, en had er uit eindelijk geen tijd meer voor.
ik had beter een speed variable kunnen maken voor de slope en de bomen, maar dat werd lastig in mijn huidige implementatie. omdat ik eerst de bomen had gemaakt, volgens de planning. maar toen nog niet rekening gehouden met de snelheid.