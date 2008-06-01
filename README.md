EPANET2-Lazarus
===============


EPANET is a dynamic water distribution system simulation model released by the United
States Environmental Protection Agency for both utilities and consultants. It uses the
standard node-link relationship common throughout most engineering programs. EPANET
was highly received in the market because it was distributed freely, and has what is
even today considered to be the industry standard computational engine. It removed
the cumbersome Hardy-Cross procedure from models and introduced what is termed
"The Hybrid-Gradient Algorithm" that takes the network and writes it into a series
of linear equations. EPANET can be used for all kinds of drinking water modelling:
Flows in pipes, Pressures at junctions, propagation of a contaminant, chlorine
concentration, water age, and even alternative scenario analysis. It can also
simulated hourly differences in water demand through the system without difficulty.

EPANET was developed using Delphi (a closed source RAD-IDE developed by Borland),
as part of a research project I had at University of Évora (Portugal) I wanted to
be able to run EPANET natively on Linux. So I started to port it from Delphi into
Lazarus. Since my scholarship has finished and I don't the time to work on this
I'm releasing so that someone interested can continue my work.

Since Lazarus didn't support MDI forms I had to make some small adjustments to the
interface but this shouldn't prevent anyone which used to EPANET to use it.
Many Lazarus bugs were fixed while porting the code, a Charting and i18n systems were also developed.

The are still two missing parts which are import:

* Printing System - EPANET original printing system is based on Windows
    Metafile (it is not supported on any other platform), I've made a
    Windows component to ease the port but it needs to be replaced with
    cross platform code. I've started to port a Delphi Print/Print Preview
    component to Lazarus with is completely cross platform but didn't had a
    chance to finish and integrate it.
* I18n - To translate EPANET into other languages the Lazarus i18n system
    should be used. I've made some patches which were merged into Lazarus
    but they aren't complete (no translation is implemented to TStrings)

EPANET in Lazarus is working ok in Windows but at least the printing system
needs to be replaced so it can run in Linux and MacOS.

This port if not in any way affiliated or support by EPA

Anyone interest in finishing this project please contact me.
