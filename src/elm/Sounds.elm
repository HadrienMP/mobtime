module Sounds exposing
    ( Image
    , Profile(..)
    , Sound
    , allProfiles
    , code
    , default
    , fromCode
    , pick
    , poster
    , title
    )

import Dict
import Random


type alias Sound =
    String


type alias Image =
    { url : String
    , alt : String
    }


type Profile
    = ClassicWeird
    | OfficeSafe
    | Riot
    | Funky
    | Kaamelott


poster : Profile -> Image
poster profile =
    { url =
        (++) "/images/sound-library/" <|
            case profile of
                ClassicWeird ->
                    "weird.webp"

                Riot ->
                    "commune.webp"

                OfficeSafe ->
                    "officesafe.jpg"

                Funky ->
                    "funky.webp"

                Kaamelott ->
                    "Kaamelott.webp"
    , alt =
        case profile of
            ClassicWeird ->
                "Photography of a man wearing a watermelon hat"

            Riot ->
                "Comic book drawing of the paris commune revolution"

            OfficeSafe ->
                "An office meeting room full of multicolored plastic balls"

            Funky ->
                "Photography of George Clinton"

            Kaamelott ->
                "Kaamelott"
    }


allProfiles : List Profile
allProfiles =
    nextProfile [] |> List.reverse


nextProfile : List Profile -> List Profile
nextProfile list =
    case List.head list of
        Nothing ->
            nextProfile (ClassicWeird :: list)

        Just ClassicWeird ->
            nextProfile (Riot :: list)

        Just Riot ->
            nextProfile (OfficeSafe :: list)

        Just OfficeSafe ->
            nextProfile (Funky :: list)

        Just Funky ->
            nextProfile (Kaamelott :: list)

        Just Kaamelott ->
            list


title : Profile -> String
title profile =
    case profile of
        ClassicWeird ->
            "Classic Weird"

        Riot ->
            "Riot"

        OfficeSafe ->
            "Office Safe"

        Funky ->
            "Funky"

        Kaamelott ->
            "Kaamelott"


code : Profile -> String
code profile =
    case profile of
        ClassicWeird ->
            "ClassicWeird"

        Riot ->
            "Riot"

        OfficeSafe ->
            "OfficeSafe"

        Funky ->
            "Funky"

        Kaamelott ->
            "Kaamelott"


fromCode : String -> Profile
fromCode string =
    allProfiles
        |> List.map (\profile -> ( code profile, profile ))
        |> Dict.fromList
        |> Dict.get string
        |> Maybe.withDefault ClassicWeird


default : Sound
default =
    "classic-weird/celebration.mp3"


pick : Profile -> Random.Generator Sound
pick profile =
    soundsOf profile
        |> (\( d, list ) -> Random.uniform d list)


soundsOf : Profile -> ( Sound, List Sound )
soundsOf profile =
    case profile of
        ClassicWeird ->
            ( "classic-weird/celebration.mp3"
            , classicWeird
            )

        Riot ->
            ( "riot/faut-plus-de-gouvernement.mp3"
            , riot
            )

        OfficeSafe ->
            ( "classic-weird/celebration.mp3"
            , officeSafe
            )

        Funky ->
            ( "funky/essence.mp3"
            , funky
            )

        Kaamelott ->
            ( "kaamelott/il_ne_comprennent_jamais_le_code.mp3"
            , kaamelottSounds
            )


riot : List Sound
riot =
    [ "riot/ca-cest-paris.mp3"
    , "riot/el-pueblo-unido.mp3"
    , "riot/france-qui-ferme-sa-gueule.mp3"
    , "riot/internationale.mp3"
    , "riot/internationale2.mp3"
    , "riot/milliards-contre-une-elite.mp3"
    , "riot/mort-aux-patrons.mp3"
    , "riot/ravachole.mp3"
    , "riot/eiffel_larue.wav.mp3"
    ]


funky : List Sound
funky =
    [ "funky/essence.mp3"
    , "funky/caravan.mp3"
    , "funky/cry.mp3"
    , "funky/do-it.mp3"
    , "funky/feuille.mp3"
    , "funky/fly.mp3"
    , "funky/little.mp3"
    , "funky/merci.mp3"
    , "funky/rock.mp3"
    , "funky/snip-snap.mp3"
    , "funky/sol.mp3"
    , "funky/stolen.mp3"
    , "funky/there.mp3"
    ]


classicWeird : List Sound
classicWeird =
    [ "classic-weird/007-james-bond-theme.mp3"
    , "classic-weird/007-sound-final.mp3"
    , "classic-weird/a-ha-take-on-me-cut-mp3.mp3"
    , "classic-weird/anthologie-de-julien-lepers.mp3"
    , "classic-weird/aroundtheworld.wav.mp3"
    , "classic-weird/banane.wav.mp3"
    , "classic-weird/blablabla.wav.mp3"
    , "classic-weird/boneym_rasputin.wav.mp3"
    , "classic-weird/breaking-bad-intro.mp3"
    , "classic-weird/cantina-band.mp3"
    , "classic-weird/carldouglas_kungfufighting.wav.mp3"
    , "classic-weird/celebration.mp3"
    , "classic-weird/chic_freak.wav.mp3"
    , "classic-weird/complotiste.mp3"
    , "classic-weird/coolio_ganstaparadise.wav.mp3"
    , "classic-weird/denis-brogniart-ah-original.mp3"
    , "classic-weird/didiersuper_gensquibossent.wav.mp3"
    , "classic-weird/digitallove.wav.mp3"
    , "classic-weird/donald-trump-fake-news-sound-effect.mp3"
    , "classic-weird/doors_strange.wav.mp3"
    , "classic-weird/drdre_stilldre.wav.mp3"
    , "classic-weird/drwho.mp3"
    , "classic-weird/eminem_slimshady.wav.mp3"
    , "classic-weird/fake-news-great.mp3"
    , "classic-weird/flashgordontheme.mp3"
    , "classic-weird/george-micael-wham-careless-whisper-1.mp3"
    , "classic-weird/got.mp3"
    , "classic-weird/hallelujahshort.swf.mp3"
    , "classic-weird/harry-potter-hedwigs-theme-short.mp3"
    , "classic-weird/i-am-your-father_rCXrfcX.mp3"
    , "classic-weird/imperial_march.mp3"
    , "classic-weird/inceptionbutton.mp3"
    , "classic-weird/indiana-jones-theme-song.mp3"
    , "classic-weird/indochine_aventurier.wav.mp3"
    , "classic-weird/its-me-mario.mp3"
    , "classic-weird/jurrasic-theme-2-hq.mp3"
    , "classic-weird/kaamelott-theme.mp3"
    , "classic-weird/kiss_madeforlovingyou.wav.mp3"
    , "classic-weird/knight-rider.mp3"
    , "classic-weird/lemon-grab-unacceptable.mp3"
    , "classic-weird/lmfao_partyrockanthem.wav.mp3"
    , "classic-weird/macron_projet_final.mp3"
    , "classic-weird/matmatah_apologie.wav.mp3"
    , "classic-weird/mc-hammer-u-cant-touch-this.mp3"
    , "classic-weird/mission-impossible.mp3"
    , "classic-weird/mjackson_beatit.wav.mp3"
    , "classic-weird/music-missionimpossibletheme.mp3"
    , "classic-weird/nyan-cat_1.mp3"
    , "classic-weird/o-bom-o-mal-e-o-feio-velho-oeste-desafio-dont-talk-duelo-desafio-armas.mp3"
    , "classic-weird/over9000.swf.mp3"
    , "classic-weird/perlin.mp3"
    , "classic-weird/poudreperlinpinpin_fqw6cN8.mp3"
    , "classic-weird/psy-gangnam-style-1.mp3"
    , "classic-weird/queen_breakfree.wav.mp3"
    , "classic-weird/rickroll.wav.mp3"
    , "classic-weird/robin-hood-1973-whistle-stop.mp3"
    , "classic-weird/smokeonthewater.wav.mp3"
    , "classic-weird/spindoctors_twoprinces.wav.mp3"
    , "classic-weird/star-wars-john-williams-duel-of-the-fates.mp3"
    , "classic-weird/super-mario-bros-ost-8-youre-dead.mp3"
    , "classic-weird/sweethomealabam.wav.mp3"
    , "classic-weird/tetris-theme.mp3"
    , "classic-weird/the-addams-family-intro-theme-song.mp3"
    , "classic-weird/the-benny-hill-show-theme-short-sound-clip-and-quote-hark.mp3"
    , "classic-weird/the-it-crowd-theme.mp3"
    , "classic-weird/the-pink-panther-theme-song-original-version.mp3"
    , "classic-weird/the-simpsons-nelsons-haha.mp3"
    , "classic-weird/the-weather-girls-its-raining-men-1-cut-mp3.mp3"
    , "classic-weird/thislove.wav.mp3"
    , "classic-weird/toto_africa.wav.mp3"
    , "classic-weird/toxic.wav.mp3"
    , "classic-weird/utini.mp3"
    , "classic-weird/we-are-the-champions-copia.mp3"
    , "classic-weird/zelda.mp3"
    ]


officeSafe : List Sound
officeSafe =
    [ "classic-weird/007-james-bond-theme.mp3"
    , "classic-weird/007-sound-final.mp3"
    , "classic-weird/a-ha-take-on-me-cut-mp3.mp3"
    , "classic-weird/anthologie-de-julien-lepers.mp3"
    , "classic-weird/aroundtheworld.wav.mp3"
    , "classic-weird/boneym_rasputin.wav.mp3"
    , "classic-weird/breaking-bad-intro.mp3"
    , "classic-weird/cantina-band.mp3"
    , "classic-weird/carldouglas_kungfufighting.wav.mp3"
    , "classic-weird/chic_freak.wav.mp3"
    , "classic-weird/coolio_ganstaparadise.wav.mp3"
    , "classic-weird/denis-brogniart-ah-original.mp3"
    , "classic-weird/digitallove.wav.mp3"
    , "classic-weird/donald-trump-fake-news-sound-effect.mp3"
    , "classic-weird/doors_strange.wav.mp3"
    , "classic-weird/drdre_stilldre.wav.mp3"
    , "classic-weird/drwho.mp3"
    , "classic-weird/eminem_slimshady.wav.mp3"
    , "classic-weird/fake-news-great.mp3"
    , "classic-weird/flashgordontheme.mp3"
    , "classic-weird/george-micael-wham-careless-whisper-1.mp3"
    , "classic-weird/got.mp3"
    , "classic-weird/hallelujahshort.swf.mp3"
    , "classic-weird/harry-potter-hedwigs-theme-short.mp3"
    , "classic-weird/i-am-your-father_rCXrfcX.mp3"
    , "classic-weird/imperial_march.mp3"
    , "classic-weird/inceptionbutton.mp3"
    , "classic-weird/indiana-jones-theme-song.mp3"
    , "classic-weird/indochine_aventurier.wav.mp3"
    , "classic-weird/its-me-mario.mp3"
    , "classic-weird/jurrasic-theme-2-hq.mp3"
    , "classic-weird/kaamelott-theme.mp3"
    , "classic-weird/kiss_madeforlovingyou.wav.mp3"
    , "classic-weird/knight-rider.mp3"
    , "classic-weird/lemon-grab-unacceptable.mp3"
    , "classic-weird/lmfao_partyrockanthem.wav.mp3"
    , "classic-weird/matmatah_apologie.wav.mp3"
    , "classic-weird/mc-hammer-u-cant-touch-this.mp3"
    , "classic-weird/mission-impossible.mp3"
    , "classic-weird/mjackson_beatit.wav.mp3"
    , "classic-weird/nyan-cat_1.mp3"
    , "classic-weird/psy-gangnam-style-1.mp3"
    , "classic-weird/queen_breakfree.wav.mp3"
    , "classic-weird/rickroll.wav.mp3"
    , "classic-weird/robin-hood-1973-whistle-stop.mp3"
    , "classic-weird/smokeonthewater.wav.mp3"
    , "classic-weird/spindoctors_twoprinces.wav.mp3"
    , "classic-weird/star-wars-john-williams-duel-of-the-fates.mp3"
    , "classic-weird/super-mario-bros-ost-8-youre-dead.mp3"
    , "classic-weird/sweethomealabam.wav.mp3"
    , "classic-weird/tetris-theme.mp3"
    , "classic-weird/the-addams-family-intro-theme-song.mp3"
    , "classic-weird/the-benny-hill-show-theme-short-sound-clip-and-quote-hark.mp3"
    , "classic-weird/the-it-crowd-theme.mp3"
    , "classic-weird/the-pink-panther-theme-song-original-version.mp3"
    , "classic-weird/the-simpsons-nelsons-haha.mp3"
    , "classic-weird/the-weather-girls-its-raining-men-1-cut-mp3.mp3"
    , "classic-weird/thislove.wav.mp3"
    , "classic-weird/toto_africa.wav.mp3"
    , "classic-weird/toxic.wav.mp3"
    , "classic-weird/we-are-the-champions-copia.mp3"
    , "classic-weird/zelda.mp3"

    -- TODO: what is love
    ]


kaamelottSounds : List Sound
kaamelottSounds =
    [ "kaamelott/il_ne_comprennent_jamais_le_code.mp3"

    -- kaamelott sounds autogenerated begin
    , "kaamelott/A-titre-purement-informatif.mp3"
    , "kaamelott/C_est_pas_comme_si_on_passait_pour_des_glands_tous_les_jours.mp3"
    , "kaamelott/Les-petits-pedestres.mp3"
    , "kaamelott/Ren_dez_vous_a_la_ta_verne_incognito.mp3"
    , "kaamelott/Soyez-souple-un-peu.mp3"
    , "kaamelott/Tout-travail-merite-salaire.mp3"
    , "kaamelott/a_la_volette1.mp3"
    , "kaamelott/a_moi_a_lassassin.mp3"
    , "kaamelott/a_mon_epoque_ca_se_faisait_pas.mp3"
    , "kaamelott/a_plus_tard.mp3"
    , "kaamelott/a_voui_vous_avez_raison.mp3"
    , "kaamelott/ah-bah-cest-sur-on-se-marre.mp3"
    , "kaamelott/ah-bah-voila-cherchez-pas-cest-hyper-flippant.mp3"
    , "kaamelott/ah-ca-quand-on-connait-pas-il-faut-se-mefier-avec-les-champignons.mp3"
    , "kaamelott/ah-cest-regle-hein-je-confirme.mp3"
    , "kaamelott/ah-une-vache-pres-cest-pas-une-science-exacte.mp3"
    , "kaamelott/ah__enfin_vous_voila_mon_ami__mais_que_se_passe_t_il_jentends_crier.mp3"
    , "kaamelott/ah_bah_alors_la_je_les_attends_les_mecs.mp3"
    , "kaamelott/ah_bah_ouais_mais_apres_il_faut_un_peu_de_technique.mp3"
    , "kaamelott/ah_bravo_bah_vous_parlez_d_un_hero.mp3"
    , "kaamelott/ah_cest_ca.mp3"
    , "kaamelott/ah_il_tape_la_ou_ca_fait_mal_hein.mp3"
    , "kaamelott/ah_nan_mais_quand_on_est_pas_habitue_c_est_drolement_impressionnant_la_magie.mp3"
    , "kaamelott/ah_non_ca_c_est_que_nous.mp3"
    , "kaamelott/ah_non_la_aujourd_hui_ca_passera_pas.mp3"
    , "kaamelott/ah_ouais_je_l_ai_fait_trop_fulgurant_la_ca_va.mp3"
    , "kaamelott/ah_ouais_vous_seriez_une_sorte_de_bi_taupe_en_fait.mp3"
    , "kaamelott/ah_oui_bravo_une_belle_lecon_de_sport.mp3"
    , "kaamelott/ah_parce_que_c_est_la_seule_alternative_que_vous_me_proposez.mp3"
    , "kaamelott/ah_qu_est_ce_que_vous_voulez_mon_petit_bohort.mp3"
    , "kaamelott/allez-quoi-on-a-besoin-dune-potion.mp3"
    , "kaamelott/allez-y-mollo-avec-la-joie.mp3"
    , "kaamelott/allez-y-vous.mp3"
    , "kaamelott/allez_boire_un_coup.mp3"
    , "kaamelott/allez_vous_preparer_mousaillon_on_largue_les_amarres_dans_une_heure.mp3"
    , "kaamelott/allez_vous_reposer_vous_l_avez_bien_merite.mp3"
    , "kaamelott/alors__a_qui_cest_quelle_est_morte_la_va_vache.mp3"
    , "kaamelott/alors_moi_jai_un_petit_probleme__jai_pas_pige_un_broc_de_ce_que_vous_bavez.mp3"
    , "kaamelott/alors_si_j_ai_bien_resume_le_truc_vous_allez_creuser_trois_pieds_et_demi_sur_toute_la_bretagne.mp3"
    , "kaamelott/apres_pour_le_detail_je_sais_pas.mp3"
    , "kaamelott/assiette_fromage.mp3"
    , "kaamelott/attendez-que-je-me-suis-jamais-quoi.mp3"
    , "kaamelott/attendez_il_faut_que_ca_soit_vrai_tout_ce_qu_on_dit_la.mp3"
    , "kaamelott/au_bout_dun_moment_on_a_prefere_plus_rien_dire.mp3"
    , "kaamelott/aujourdhui_ya_du_dessert.mp3"
    , "kaamelott/ave_cesar.mp3"
    , "kaamelott/avez_de_la_chance.mp3"
    , "kaamelott/bah-alors-884-charrettes-de-bouses.mp3"
    , "kaamelott/bah-ca-depend-a-partir-de-quand.mp3"
    , "kaamelott/bah-on-a-pas-de-technique-mais-cest-comme-tout.mp3"
    , "kaamelott/bah_si_il_n_y_avait_que_les_oiseaux_elle_est_a_moitie_givree_de_toute_facon_on_ne_peut_pas_tout_relever_non_plus.mp3"
    , "kaamelott/bateau-nage.mp3"
    , "kaamelott/ben_nous_on_a_cru_que_cetait_la_pour_faire_joli.mp3"
    , "kaamelott/ben_oui_cest_une_rime_triple__blanche_et_seche_poitrine_et_prairie_de_notre_enfance.mp3"
    , "kaamelott/bibelots-mongol-parthenon.mp3"
    , "kaamelott/bien_manger_cest_important.mp3"
    , "kaamelott/biensur-ils-ont-que-ca-a-foutre-les-paysans.mp3"
    , "kaamelott/bon-de-toute-facon.mp3"
    , "kaamelott/bon_bah_aller_on_demarre_et_ouvrez_les_echauguettes.mp3"
    , "kaamelott/bon_bah_ca_va_on_plaisante.mp3"
    , "kaamelott/bon_bah_je_vais_voir_ce_que_je_peux_faire.mp3"
    , "kaamelott/bon_ben_revolte.mp3"
    , "kaamelott/bon_je_peux_pas_penser_a_tout_la.mp3"
    , "kaamelott/bon_on_va_commencer_les_negociations.mp3"
    , "kaamelott/bonjour_la_pedagogie.mp3"
    , "kaamelott/boule-de-feu-boule-de-feu.mp3"
    , "kaamelott/bucher1.mp3"
    , "kaamelott/bucher2.mp3"
    , "kaamelott/buffet_a_vaisselle.mp3"
    , "kaamelott/burgonde_ou_anglais.mp3"
    , "kaamelott/c_est_cotelette_que_vous_comprenez_pas.mp3"
    , "kaamelott/c_est_pas_parce_qu_ils_ont_trahi_que_c_est_plus_des_allies.mp3"
    , "kaamelott/ca-ca-doit-etre-du-code-parce-que-ca-veut-rien-dire.mp3"
    , "kaamelott/ca_change_tout.mp3"
    , "kaamelott/ca_me_plait_qu_a_moitie.mp3"
    , "kaamelott/ca_va_encore_faire_des_discussions_a_rallonge.mp3"
    , "kaamelott/ca_va_si_faut_sonner_lalerte_vous_pouvez_bien_attendre_que_je_revienne_nan.mp3"
    , "kaamelott/ca_va_un_peu_trop_vite_pour_moi.mp3"
    , "kaamelott/ca_vous_regarde_pas_cest_secret_ok.mp3"
    , "kaamelott/casuffit.mp3"
    , "kaamelott/catastrophe.mp3"
    , "kaamelott/ce-serait-hyper.mp3"
    , "kaamelott/centurion_caius_camilus_lulululu.mp3"
    , "kaamelott/cest-marrant-les-petits-bouts-de-fromage-par-terre.mp3"
    , "kaamelott/cest-pas-du-burgonde-ca.mp3"
    , "kaamelott/cest-pas-du-tout-mon-anniversaire.mp3"
    , "kaamelott/cest-pas-pour-rien-quon-mappelle-le-fourbe.mp3"
    , "kaamelott/cest-un-scandale.mp3"
    , "kaamelott/cest-une-blague.mp3"
    , "kaamelott/cest_beau_quand_meme.mp3"
    , "kaamelott/cest_bien_fait.mp3"
    , "kaamelott/cest_chaud_quand_meme.mp3"
    , "kaamelott/cest_dur.mp3"
    , "kaamelott/cest_facile_on_peut_jouer_soit_avec_des_haricots_soit_avec_des_lentilles.mp3"
    , "kaamelott/cest_interessant.mp3"
    , "kaamelott/cest_lanniversaire_dans_tous_les_recoins.mp3"
    , "kaamelott/cest_le_grand_qui_a_dit.mp3"
    , "kaamelott/cest_moi_ou_il_y_a_une_ambiance_de_merde.mp3"
    , "kaamelott/cest_pas_faux1.mp3"
    , "kaamelott/cest_pas_faux2.mp3"
    , "kaamelott/cest_pas_jo_le_rigolo.mp3"
    , "kaamelott/cest_pas_une_sinecure.mp3"
    , "kaamelott/cest_plus_filiforme.mp3"
    , "kaamelott/cest_prodigieux.mp3"
    , "kaamelott/cest_que_cest_pas_une_blague.mp3"
    , "kaamelott/cest_tellement_facile_que_je_vais_peut_etre_systematise_le_processus.mp3"
    , "kaamelott/cest_une_catastrophe_souffle.mp3"
    , "kaamelott/cest_vrai_quelle_reste.mp3"
    , "kaamelott/charmant.mp3"
    , "kaamelott/chevalierisation.mp3"
    , "kaamelott/chui_un_marteau_moi.mp3"
    , "kaamelott/comme-la-mare-aux-canards.mp3"
    , "kaamelott/compote.mp3"
    , "kaamelott/comprend_jamais_un_broc_de_ce_quon_dit.mp3"
    , "kaamelott/dans_la_vie.mp3"
    , "kaamelott/dans_trois_jours_cest_les_vacances.mp3"
    , "kaamelott/de-toute-facon-les-reunions-cest-2-fois-par-mois.mp3"
    , "kaamelott/de_quoi_desole_excusez_moi_j_ecoutais_pas.mp3"
    , "kaamelott/de_tout_facon_on_dit_le_nord_selon_comment_on_est_tourne_ca_change_tout.mp3"
    , "kaamelott/deja_que_ca_me_gonfle_de_porter_des_messages.mp3"
    , "kaamelott/demain-cest-demain.mp3"
    , "kaamelott/demi_journee_vous_attend.mp3"
    , "kaamelott/des_fois_on_a_pas_le_choix_faut_sacrifier_les_jeunes.mp3"
    , "kaamelott/difference_concrete_avec_des_briques.mp3"
    , "kaamelott/dites_tirez_vous.mp3"
    , "kaamelott/donc-cette-fiole.mp3"
    , "kaamelott/ecoutez_je_comprend_rien_a_ce_que_vous_faites.mp3"
    , "kaamelott/embobinage_dans_l_air.mp3"
    , "kaamelott/enfin-quand-cest-demande-gentiment.mp3"
    , "kaamelott/enquille.mp3"
    , "kaamelott/epique.mp3"
    , "kaamelott/essayez_de_faire_des_phrases_pour_vous_deja.mp3"
    , "kaamelott/est-ce_que_vous_pouvez_vous_barrer_maintenant.mp3"
    , "kaamelott/est_ce_que_peut_servir_elan_pigeon.mp3"
    , "kaamelott/est_ce_quil_sait_nager_deja.mp3"
    , "kaamelott/et-ca-cest-du-nougat.mp3"
    , "kaamelott/et-celle-la-jirai-pas-me-coucher-avant-de-lavoir-bousillee.mp3"
    , "kaamelott/et-moi-je-me-suis-fait-derober-de-lalimentation-tout-le-long-du-voyage.mp3"
    , "kaamelott/et_puis_quoi_encore.mp3"
    , "kaamelott/et_puis_y_a_toujours_une_proportion_de_secoues.mp3"
    , "kaamelott/et_si_vous_arretiez_de_gueuler.mp3"
    , "kaamelott/evidemment_quelquun.mp3"
    , "kaamelott/exagerer_non.mp3"
    , "kaamelott/excusez_moi_hein_je_ne_connais_pas_encore_bien_vos_noms.mp3"
    , "kaamelott/faisons_table_en_marbre.mp3"
    , "kaamelott/faites_gaffe_aux_pieges_a_loups.mp3"
    , "kaamelott/faut_ce_qui_faut.mp3"
    , "kaamelott/faut_que_je_retourne_a_la_ferme_de_mes_vieux.mp3"
    , "kaamelott/fer-a-cheval.mp3"
    , "kaamelott/fleur_en_bouquet.mp3"
    , "kaamelott/hein_titi.mp3"
    , "kaamelott/honnetement_je_connais_pas_le_mot_la.mp3"
    , "kaamelott/humilite_infiltration.mp3"
    , "kaamelott/il-faut-affranchir-nos-compagnons.mp3"
    , "kaamelott/il-n-y-a-pas-dequivoque-vous-etes-franchement-un-bourrin.mp3"
    , "kaamelott/il_est_pas_beau_mon_graal.mp3"
    , "kaamelott/il_ne_comprennent_jamais_le_code.mp3"
    , "kaamelott/ils-commencent-par-apprendre-a-lire.mp3"
    , "kaamelott/ils-se-sont-pas-leve-2.mp3"
    , "kaamelott/ils-se-sont-pas-leve-3.mp3"
    , "kaamelott/ils_sortent_bien_de_quelques_part.mp3"
    , "kaamelott/incandescent.mp3"
    , "kaamelott/insoupconnable.mp3"
    , "kaamelott/interprete.mp3"
    , "kaamelott/intro_comaque.mp3"
    , "kaamelott/j_ai_fais_pile_comme_vous_avez_dis_tout_au_feu_de_bois.mp3"
    , "kaamelott/j_ai_le_droit_d_etre_4_jours_pas_chez_moi.mp3"
    , "kaamelott/j_ai_pas_eu_le_temps_d_enlever_mon_armure.mp3"
    , "kaamelott/j_aimerais_bien_qu_on_commence_a_me_considerer_en_tant_que_tel.mp3"
    , "kaamelott/j_apprecie_les_fruits_au_sirop.mp3"
    , "kaamelott/jai-le-droit-detre-4-jours-pas-chez-moi.mp3"
    , "kaamelott/jai_toujours_ete_fascine_par_le_monde_paysan.mp3"
    , "kaamelott/je-l-ai-pas-dit-fort.mp3"
    , "kaamelott/je-moccupe-de-tout-dite-oui.mp3"
    , "kaamelott/je-suis-desole-jai-pas-eu-le-temps-de-potasser-les-formules.mp3"
    , "kaamelott/je-vous-ai-toujours-dit-ce-que-vous-faites-avec-les-chiffres.mp3"
    , "kaamelott/je_connais_que_le_cri.mp3"
    , "kaamelott/je_crois_pas_que_vous_soyez_le_symbole_de_la_nation_bretonne.mp3"
    , "kaamelott/je_l_ai_perdu.mp3"
    , "kaamelott/je_ne_mange_pas_de_graines.mp3"
    , "kaamelott/je_refuse_daller_me_battre.mp3"
    , "kaamelott/je_sens_que_ce_va_encore_etre_capital.mp3"
    , "kaamelott/je_vais_devenir_paladin.mp3"
    , "kaamelott/je_vais_pas_faire_des_aller_retours_3_fois_par_jours.mp3"
    , "kaamelott/je_veux_mhabiller_de_lierre_et_me_coiffer_de_roseaux.mp3"
    , "kaamelott/je_vois_pas_le_rapport_avec_bretagne.mp3"
    , "kaamelott/je_vois_trouble.mp3"
    , "kaamelott/je_vous_disais_que_j_etais_victime_des_colifiches.mp3"
    , "kaamelott/jpeux_pas_vous_dire.mp3"
    , "kaamelott/jsais_pas_cqui_vous_faut.mp3"
    , "kaamelott/jsuis_a_mon_poste_cest_pas_le_cas_de_tout_le_monde.mp3"
    , "kaamelott/jvous_fait_confiance.mp3"
    , "kaamelott/jy_vais_javoine.mp3"
    , "kaamelott/kaamelott_cest_pas_une_cooperative_bovine.mp3"
    , "kaamelott/la-blague-est-pas-drole.mp3"
    , "kaamelott/la-chevre-a-beler-5-min.mp3"
    , "kaamelott/la-tournure-est-plus-graduelle.mp3"
    , "kaamelott/la_bouffe_est_interdite.mp3"
    , "kaamelott/la_dedans_carbure.mp3"
    , "kaamelott/laissez_le_a_lair.mp3"
    , "kaamelott/le-seigneur-perceval-ne-se-met-jamais-en-situation-dangeureuse.mp3"
    , "kaamelott/le_graal_par_ci_le_graal_par_la.mp3"
    , "kaamelott/le_gras_cest_la_vie.mp3"
    , "kaamelott/le_pognon_ca_va_ca_vient.mp3"
    , "kaamelott/le_poisson_le_petit_poisson.mp3"
    , "kaamelott/les-gars-me-regardent-avec-des-billes-comme-ca-et-ils-decrochent.mp3"
    , "kaamelott/les_pattes_de_canard.mp3"
    , "kaamelott/maintenant-il-faut-nous-ecouter-parce-que-la-on-en-a-gros.mp3"
    , "kaamelott/mais-allez-y-cest-pour-vous-stimuler-bon-dieu.mp3"
    , "kaamelott/mais-pas-du-tout.mp3"
    , "kaamelott/mais_evidemment_que_si.mp3"
    , "kaamelott/mais_faut_pas_deconner_ils_y_sont_pour_rien.mp3"
    , "kaamelott/mais_je_vous_ai_dis_que_c_etait_important.mp3"
    , "kaamelott/mais_moi_je_vous_previens_jy_connais_rien_en_champignon.mp3"
    , "kaamelott/mais_tout_a_fait.mp3"
    , "kaamelott/mais_vous_savez_ce_que_ca_veux_dire_au_moins.mp3"
    , "kaamelott/mavez_lair_en_forme.mp3"
    , "kaamelott/merci_de_rien.mp3"
    , "kaamelott/merciiiii.mp3"
    , "kaamelott/meteo.mp3"
    , "kaamelott/mettre_du_beurre_au_fond_du_plat.mp3"
    , "kaamelott/mi_ours_mi_scorpion.mp3"
    , "kaamelott/moi-pour-quon-me-reconnaisse-faut-juste-2-3-coups-de-pinceaux.mp3"
    , "kaamelott/moi_a_lepoque_je_voulais_faire_voeux_de_pauvrete_--_et_alors__--_ben_avec_le_pognon_que_j.mp3"
    , "kaamelott/moi_il_faut_que_j_enleve_mon_armure.mp3"
    , "kaamelott/moi_jai_toujours_dit2.mp3"
    , "kaamelott/moi_je_serais_vous_je_vous_ecouterais.mp3"
    , "kaamelott/moi_non_plus_je_vois_rien.mp3"
    , "kaamelott/nan-cest-nimporte-quoi.mp3"
    , "kaamelott/nan-mais-en-vrai-pas-sur-la-carte.mp3"
    , "kaamelott/nan-mais-quand-meme.mp3"
    , "kaamelott/nempeche_que_cest_moi_qui_avait_propose.mp3"
    , "kaamelott/ni_vu_ni_connu.mp3"
    , "kaamelott/non-mais-biensur-donc-vous-vous-degommez-les-souris-au-maillet.mp3"
    , "kaamelott/non-mais-franchement-je-serais-nous-je-vous-ecouterais.mp3"
    , "kaamelott/non-on-a-fait-3-bornes-sil-vous-plait.mp3"
    , "kaamelott/non_mais_je_sens_bien_que_vous_essayer_de_me_dire_quelque_chose.mp3"
    , "kaamelott/non_psychologique_c_est_tout_ce_qui_est_a_la_campagne.mp3"
    , "kaamelott/notre-enchanteur-minforme-que-dhabitude-il-y-arrive-tres-bien.mp3"
    , "kaamelott/oh-la-vache-mais-cest-nul.mp3"
    , "kaamelott/oh-mais-vous-etes-des-malades.mp3"
    , "kaamelott/oh_ca_fait_rien.mp3"
    , "kaamelott/oh_cest_la_vacherie_ca.mp3"
    , "kaamelott/oh_et_puis_j_en_ai_marre.mp3"
    , "kaamelott/oh_la_vache.mp3"
    , "kaamelott/ok_on_va_arreter_le_tire_avec_les_defis.mp3"
    , "kaamelott/on-est-indestructible.mp3"
    , "kaamelott/on_a_pas_regarde_dans_les_f.mp3"
    , "kaamelott/on_en_a_gros.mp3"
    , "kaamelott/on_essaie_de_catapulter_un_danseur.mp3"
    , "kaamelott/on_est_forts.mp3"
    , "kaamelott/on_est_pas_sorti_du_sable.mp3"
    , "kaamelott/on_fera_tintin_pour_le_clafoutis.mp3"
    , "kaamelott/on_plaisante_on_plaisante.mp3"
    , "kaamelott/ouais-cest-grace-a-notre-arme-secrete.mp3"
    , "kaamelott/ouais_cest_mortel_ouais.mp3"
    , "kaamelott/oui-peut-etre-oui-oui.mp3"
    , "kaamelott/oui.mp3"
    , "kaamelott/oui_ben_non.mp3"
    , "kaamelott/oui_enfin_je_me_comprends.mp3"
    , "kaamelott/oui_et_ben_moi_je_vous_donne_lordre_de_lui_preter_votre_corne_parce_que_quand_on_est_gentil_on_prete.mp3"
    , "kaamelott/oui_oh_ca_va_je_connais_le_couplet_on_est_fatigue_on_est_fatigue_vous_me_le_cancane_depuis_midi.mp3"
    , "kaamelott/oui_ou_une_fissure_a_colmater_dans_un_muret.mp3"
    , "kaamelott/parce-que-vous-etes-en-train-de-faire-une-connerie-la-quand-meme.mp3"
    , "kaamelott/parce_que_la_quite_a_se_faire_reperer_on_prendrait_moins_de_risque_a_faire_venir_un_orchestre.mp3"
    , "kaamelott/pas-moyen-de-piger-un-broc-de-ce-quil-dit.mp3"
    , "kaamelott/pas_de_quoi_en_chier_une_galette.mp3"
    , "kaamelott/pas_du_tout_les_lapins_les_lapins_c_est_gentil.mp3"
    , "kaamelott/pas_foutu_de_savoir_son_nom.mp3"
    , "kaamelott/pas_la_moindre_idee.mp3"
    , "kaamelott/patience-plat-sans-sauce.mp3"
    , "kaamelott/pays_de_galles_independant.mp3"
    , "kaamelott/petit_a_petit_vers_plus_dautonomie.mp3"
    , "kaamelott/petit_ton_decale.mp3"
    , "kaamelott/peur_justifiee.mp3"
    , "kaamelott/peut-etre-meme-que-je-mette-une-armure.mp3"
    , "kaamelott/pfff_c_est_pour_ca_que_je_pane_rien_aux_livres_moi_ca_veut_pas_dire_ce_qu_il_y_a_marque.mp3"
    , "kaamelott/pfiou-pfiou-pfiou.mp3"
    , "kaamelott/politique_de_l_autruche.mp3"
    , "kaamelott/pour_le_detail_je_sais_pas.mp3"
    , "kaamelott/putain_faut_vraiment_qu_on_se_groulle.mp3"
    , "kaamelott/qu-est-ce-que-cest-cette-tisane.mp3"
    , "kaamelott/qu-est-ce-qui-a-dautre-qui-pue-sinon.mp3"
    , "kaamelott/qu-est_ce_dire_que_ceci.mp3"
    , "kaamelott/qu_est_ce_que_vous_voulez_savoir_allez_vous_vous_magner_le_tronc_maintenant.mp3"
    , "kaamelott/quand-il-a-rien-a-dire-il-dit-rien.mp3"
    , "kaamelott/quand_je_comprends_pas_je_reponds_pas.mp3"
    , "kaamelott/quest-ce-que-cest-ce-nouveau-genre-seigneur-lancelot.mp3"
    , "kaamelott/quest-ce-que-vous-racontez-cest-pas-ca.mp3"
    , "kaamelott/quest_ce_que_vous_attendez_pour_la_couper.mp3"
    , "kaamelott/quest_ce_qui_est_petit_et_marron.mp3"
    , "kaamelott/quoi-mais-cest-un-scandale.mp3"
    , "kaamelott/regardez_moi_ce_petit_navet.mp3"
    , "kaamelott/regardez_moi_cette_meule.mp3"
    , "kaamelott/remarquez-jai-un-pote-poissonier.mp3"
    , "kaamelott/restez_pas_plante_la_comme_un_cepe.mp3"
    , "kaamelott/rien-ca-fait-rien-cassez-vous.mp3"
    , "kaamelott/rien_a_carer.mp3"
    , "kaamelott/salut-sire-je-trouve-quil-fait-beau-mais-encore-frais-mais-beau.mp3"
    , "kaamelott/sans-deconner-faut-pas-y-aller-demain.mp3"
    , "kaamelott/sans_etre_totalement_repoussant_il_n_y_a_pas_de_quoi_bousculer_une_charette.mp3"
    , "kaamelott/scorpion_entoure_par_le_feu.mp3"
    , "kaamelott/si-on-peut-sen-farcir-un-cest-toujours-ca-de-pris-quoi.mp3"
    , "kaamelott/si_vous_etes_vendeur.mp3"
    , "kaamelott/signe_de_vouloir_discuter.mp3"
    , "kaamelott/sils_sont_equidistants_on_peut_reperer_le_dragon.mp3"
    , "kaamelott/simple_deduction_mon_oncle.mp3"
    , "kaamelott/sire-je-ne-suis-pas-homme.mp3"
    , "kaamelott/sire_vous_me_flattez.mp3"
    , "kaamelott/sortez-vous_les_doigts_du_cul.mp3"
    , "kaamelott/stand_de_crepes.mp3"
    , "kaamelott/sur_de_son_coup.mp3"
    , "kaamelott/tatan_elle_fait_des_flans.mp3"
    , "kaamelott/tempora_mori.mp3"
    , "kaamelott/tete-roupiller-couloir.mp3"
    , "kaamelott/tout_dans_le_furtif.mp3"
    , "kaamelott/tres_bien.mp3"
    , "kaamelott/tres_en_colere.mp3"
    , "kaamelott/trois_jours_voyages_trois_jours_chez_vous.mp3"
    , "kaamelott/tropgentil.mp3"
    , "kaamelott/tsoin-tsoin.mp3"
    , "kaamelott/un_bon_quart_dheure.mp3"
    , "kaamelott/urgan-lhomme-goujon.mp3"
    , "kaamelott/venez-mouvriiir.mp3"
    , "kaamelott/victoriae_mundis.mp3"
    , "kaamelott/voeux_de_pauvrete_jarrivais_pas_a_concilier.mp3"
    , "kaamelott/voila_cest_pro.mp3"
    , "kaamelott/voila_passez_moi_la_canne_a_peche.mp3"
    , "kaamelott/voila_zut.mp3"
    , "kaamelott/vous-allez-me-promettre-de-pas-y-foutre-les-pieds.mp3"
    , "kaamelott/vous-avez-pas-pris-le-temps-de-vous-habituer-au-fruit.mp3"
    , "kaamelott/vous-en-mettez-pas-trop.mp3"
    , "kaamelott/vous-faites-pas-la-gueule-la.mp3"
    , "kaamelott/vous-me-dites-il-faut-quelque-chose-de-festif.mp3"
    , "kaamelott/vous-pouvez-aller-vous-gratter.mp3"
    , "kaamelott/vous-vous-devriez-arreter-de-sourire.mp3"
    , "kaamelott/vous_admettrez_que_vous_etes_hors_normes.mp3"
    , "kaamelott/vous_allez_pas_commencer_avec_vos_termes_pourris.mp3"
    , "kaamelott/vous_avez_pas_limpression_que_je_suis_dans_une_baignoire.mp3"
    , "kaamelott/vous_balader_avec_une_cuillere_a_soupe_ca_changerait_rien.mp3"
    , "kaamelott/vous_comprenez_le_principe.mp3"
    , "kaamelott/vous_devriez_commencer_par_organiser_le_merdier_que_vous_avez_la_dedans.mp3"
    , "kaamelott/vous_la_crachez_votre_pastille.mp3"
    , "kaamelott/vous_laissez_pas_embobiner_ils_cherchent_a_vous_rembobiner.mp3"
    , "kaamelott/vous_nous_utilisez_bon_gre_mal_gre_pour_arriver_sur_la_fin.mp3"
    , "kaamelott/vous_rigolez_jespere.mp3"
    , "kaamelott/vraiment_impressionnant.mp3"
    , "kaamelott/wooouuuhouhouhou_c_est_mortel.mp3"
    , "kaamelott/y_en_a_marre_de_se_comporter_comme_des_sagouins.mp3"
    , "kaamelott/ya_pas_de_mal.mp3"
    , "kaamelott/ya_pas_un_pigeon_pour_envoyer_un_message.mp3"
    , "kaamelott/zut_la.mp3"

    -- kaamelott sounds autogenerated end
    ]
