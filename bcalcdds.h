#ifndef __BELING__BCALC_BRIDGE_SOLVER__
#define __BELING__BCALC_BRIDGE_SOLVER__

/** @file
 * Bridge Calculator API header file.
 */

/*! \mainpage Bridge Calculator (C API)

\section about About
This is documentation for C API (and library) for Bridge Calculator engine, a fast double dummy solver.

Bridge Calculator and its C API are develop by Piotr Beling.
More information can be found on a program web-page: http://bcalc.w8.pl/

\section license License
Bridge Calculator (and its C API) is freeware for private and non-commercial use (use to develop freeware applications)
and it's distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

Each distributed product which use this API/library should includes readable for end-user information about this fact
and link to Bridge Calculator web-page: http://bcalc.w8.pl/

If you need license to develop commercial (payment) application, please contact with me: qwak82@gmail.com

\section example Example
@code
//create solver
BCalcDDS* solver = bcalcDDS_new("PBN", "N:.63.AKQ987.A9732 A8654.KQ5.T.QJT6 J973.J98742.3.K4 KQT2.AT.J6542.85", BCALC_NT, BCALC_PLAYER_NORTH);
if (solver != 0) exit(1);	//out of memory error
//use it, print player to play, and how many tricks his line can take:
printf("%c playes, and he with partner will be able to take %d tricks.\n",
	bcalc_playerSymbol(bcalcDDS_getPlayerToPlay(solver)),
	bcalcDDS_getTricksToTake(solver)
);
bcalcDDS_exec(solver, "7D x x");	//play 7 of dimamonds, and two smallest diamonds
//print current situation:
printf("%c playes, and he with partner will be able to take %d tricks.\n",
	bcalc_playerSymbol(bcalcDDS_getPlayerToPlay(solver)),
	bcalcDDS_getTricksToTake(solver)
);
bcalcDDS_delete(solver);	//and delete (free memory)
@endcode

\section names Names
All names defined by library have prefixes:
- BCALC_ - consts (defines)
- BCalc - types (for example: BCalcDDS)
- bcalc - functions and macros
	- bcalcDDS - functions which operates on BCalcDDS (almost all takes BCalcDDS* as first argument)

\section changes Changes and Backward Compatibility
- ver. 14020 (5 II 2014):
	- compatibility: API - yes (changes of application source are not required), ABI - yes (recompilation of application is not required),
	- new function bcalcDDS_getTricksToTakeEx, this is extendend version of bcalcDDS_getTricksToTake and takes new, optional arguments: tricks_target and card,
	- new function bcalcDDS_clone,
	- in many places, the ASCII symbols of the suits, strains or players are accepted (as well as BCALC_* constants)
*/

#ifdef __cplusplus
extern "C" {
#endif

/**
Version of bcalc engine API.

Bridge Calculator program version (unsigned integer in form YYMMN) on which base engine.
Note that engine is released less often than program (in some program release engine is not changed).
@see @ref bcalc_runtimeVersion
*/
#define BCALC_VERSION 14020

/**
Handler to bcalc double dummy solver.

Double dummy solver represents game with history of play.
It also stores many values which was calculated for it.

Usualy you should only use pointer to this type.
*/
typedef struct BCalcDDS BCalcDDS;

#define BCALC_PLAYER_NORTH 0	///<North player
#define BCALC_PLAYER_EAST 1		///<East player
#define BCALC_PLAYER_SOUTH 2	///<South player
#define BCALC_PLAYER_WEST 3		///<West player

/**
Convert player number to player symbol.
@param player player number, one of BCALC_PLAYER_*
@return player symbol, one of 'N', 'E', 'S', 'W'
*/
#define bcalc_playerSymbol(player) ("NESW"[player])

/**
Calculate hand relative to given one.
@param hand one of BCALC_PLAYER_*
@param delta clock-wise delta, +1 to next player (in clock-wise)
@return calculated hand, one of BCALC_PLAYER_* value
*/
#define bcalc_nextHand(hand, delta) (((hand)+(delta))&3)    //or (((hand)+(delta))%4)

/**
Calculate leader hand using @p declarer hand.
@param declarer
@return player on lead in deal where @p declarer is declarer
*/
#define bcalc_declarerToLeader(declarer) bcalc_nextHand(declarer, 3)

#define BCALC_SUIT_CLUBS 0		///<Club suit number
#define BCALC_SUIT_DIAMONDS 1	///<Diamond suit number
#define BCALC_SUIT_HEARTS 2		///<Hearts suit number
#define BCALC_SUIT_SPADES 3		///<Spades suit number

#define BCALC_NT 4			///<No trump

/**
Convert @p suit number to its ASCII symbol.
@param suit suit, one of BCALC_SUIT_*
@return suit symbol, one of 'C', 'D', 'H', 'S', 'N' (for NT)
*/
#define bcalc_suitSymbol(suit) ("CDHSN"[suit])

/**
Get the version of the API used by the runtime library.
@return the version of the API used by the (typically: dynamic) runtime library
@see @ref BCALC_VERSION
*/
unsigned bcalc_runtimeVersion();

/**
Construct new solver.

Each solver has own memory and it is thread safety to operate on multiple solvers at the same time,
but it is not safety to call more than one bcalcDDS_* function for one solver at the same time.
@param format Format of @p hands, for example "NESW", "ESWN", ..., "PBN", "LIN":
- "PBN" is Portable Bridge Notation like format,
- "lin" is BBO .lin like format,
- rest show order of hands.
@param hands Players hands. Each player must have the same number of cards.
    To get situation inside trick, you should create trick's beginning situation and call bcalcDDS_exec to play cards included in current trick.
@param strain one of BCALC_SUIT_* or BCALC_NT constant or ASCII symbol of strain (one of: 'c', 'C', 'd', 'D', 'h', 'H', 's', 'S', 'n', 'N')
@param leader player on lead, one of BCALC_PLAYER_* constant or player ASCII symbol (one of: 'n', 'N', 'e', 'E', 's', 'S', 'w', 'W')
@return Constructed solver or NULL in case of out of memory.
Returned solver can have error set in case of deal parser error, invalidate strain or leader (see @ref bcalcDDS_getLastError)
and in such case you should not use that solver.
In all cases constructed solver should be freed, after use, by @ref bcalcDDS_delete.
*/
extern BCalcDDS* bcalcDDS_new(const char* format, const char* hands, int strain, int leader);

/**
 * Clone the state of the solver @p to_clone.
 * @param to_clone solver to clone
 * @return copy of @p to_clone or NULL (in case of out of memory, or if @p to_clone is NULL).
 * Returned copy, as well as @p to_clone, must by freed, after use, by @ref bcalcDDS_delete
 */
extern BCalcDDS* bcalcDDS_clone(BCalcDDS* to_clone);

/**
Delete double dummy solver, free its memory.
@param solver constructed by @ref bcalcDDS_new, double dummy solver to delete, it is safe to pass NULL pointer (function do nothing in such a case)
*/
extern void bcalcDDS_delete(BCalcDDS* solver);

/**
Get last error string.
@param solver bcalc double dummy solver
@return last error message or NULL if no error, pointer to internal solver buffer (valid up to next bcalcDDS_* call for solver passed as argument)
*/
extern const char* bcalcDDS_getLastError(const BCalcDDS* solver);

/**
Clear error message.

After call, bcalcDDS_getLastError(solver) will return NULL.
@param solver bcalc double dummy solver
*/
extern void bcalcDDS_clearError(BCalcDDS* solver);

/**
Execute commands which can modify the state of given @p solver (current situation in game represented by it).
@param solver bcalc double dummy solver
@param cmds commands to execute

Commands should be separated by spaces and each can be one of:
- \<C\>\<S\> - where \<C\> is card symbol (like: A, Q, T, 6), \<S\> is suit symbol (one of: C, D, H, S), play choosen card
- x - play smallest possible card following played suit
- u - unplay one card
- ut - unplay last trick
- ua - unplay all tricks
*/
extern void bcalcDDS_exec(BCalcDDS* solver, const char* cmds);

/**
Calculate number of tricks possible to take (same as bcalcDDS_getTricksToTakeEx(solver, -1, 0)).
@param solver bcalc double dummy solver
@return number of tricks possible to take (in future) by line which plays in current situation
*/
extern int bcalcDDS_getTricksToTake(BCalcDDS* solver);

/**
If @p tricks_target == -1, calculate number of tricks possible to take.
If @p tricks_target >= 0 check if @p tricks_target number of tricks are possible to take.
Optionaly, if @c card != 0: it suppose that player to play starts with playing @c card.
@param solver bcalc double dummy solver
@param tricks_target (optional, -1 to ignore) target number of tricks to take by player to play
@param card if not 0 must include description of one card, held by player to play, in format: \<C\>\<S\> - where \<C\> is card symbol, \<S\> is suit symbol (can also be 'x' for smallest possible card following played suit)
@return
    - If @p tricks_target == -1, it returns number of tricks possible to take (in future) by line which plays in current situation.
    - If @p tricks_target >= 0, it returns 1 only if line which plays in current situation can take @p tricks_target tricks in future.
    - In case of error (possible when @p card has wrong format) it returns -1.
*/
extern int bcalcDDS_getTricksToTakeEx(BCalcDDS* solver, int tricks_target, const char* card);

/**
Get strain.
@param solver bcalc double dummy solver
@return strain of game connected with @p solver
*/
extern int bcalcDDS_getTrump(BCalcDDS* solver);

/**
Set new strain and reset deal to initial state (undo all tricks).
@param solver bcalc double dummy solver
@param new_trump new strain to set for game connected with @p solver, one of BCALC_SUIT_* or BCALC_NT constant or ASCII symbol (one of: 'c', 'C', 'd', 'D', 'h', 'H', 's', 'S', 'n', 'N')
*/
extern void bcalcDDS_setTrumpAndReset(BCalcDDS* solver, int new_trump);

/**
Reset deal to initial state (undo all tricks) and change player on lead.

Note that this doesn't clear transposition table, so calculation results which was colecting with an other player on lead will be still use.
So if you need to iterate over all leader-strains pairs, and calculate number of tricks to take for each,
it is much more effective to iterate over strains in outer loop and over leaders in inner loop.
@param solver bcalc double dummy solver
@param new_leader player on lead, one of BCALC_PLAYER_* constant or player ASCII symbol (one of: 'n', 'N', 'e', 'E', 's', 'S', 'w', 'W')
*/
extern void bcalcDDS_setPlayerOnLeadAndReset(BCalcDDS* solver, int new_leader);

/**
Get numbers of tricks which have been already taken by players in game connected with @p solver.
@param solver bcalc double dummy solver
@param result buffer, array of minimum length of 4, place to store calculated numbers of tricks
@return @p result array, number of tricks taken by players, use BCALC_PLAYER_* as this array indexes
*/
extern int* bcalcDDS_getTricksTaken(BCalcDDS* solver, int* result);

/**
Get number of cards which left to play in game connected with @p solver.
@param solver bcalc double dummy solver
@return how many cards left to play to deal end, integer from 0 to 52
*/
extern int bcalcDDS_getCardsLeftCount(BCalcDDS* solver);

/**
Get cards owned by given @p player in given @p suit.
@param solver bcalc double dummy solver
@param player player, one of BCALC_PLAYER_* or player ASCII symbol (one of: 'n', 'N', 'e', 'E', 's', 'S', 'w', 'W')
@param suit suit, one of BCALC_SUIT_* or suit symbol in ASCII (one of: 'c', 'C', 'd', 'D', 'h', 'H', 's', 'S')
@param result buffer, place for results, safe length is 14 (13 cards and terminated zero)
@return @p result, zero-ended string, suits written using symbols from: AKQJT98765432,
 in case of error @p result in unchanged form
*/
extern char* bcalcDDS_getCards(BCalcDDS* solver, char* result, int player, int suit);

/**
Get player which should play now.
@param solver bcalc double dummy solver
@return player which should play now in game connected with given @p solver
*/
extern int bcalcDDS_getPlayerToPlay(BCalcDDS* solver);

/**
Get cards possible to play in given @p suit by player who should play.
@param solver bcalc double dummy solver
@param result buffer, place for results, safe length is 14 (13 cards and terminated zero)
@param suit suit, one of BCALC_SUIT_* or suit symbol in ASCII (one of: 'c', 'C', 'd', 'D', 'h', 'H', 's', 'S')
@return @p result, zero-ended string, suits written using symbols from: AKQJT98765432,
 in case of error @p result in unchanged form
*/
extern char* bcalcDDS_getCardsToPlay(BCalcDDS* solver, char* result, int suit);

/**
Get card played as a @p whenIndex (when card played on first lead has index 0).
@param solver bcalc double dummy solver
@param whenIndex card index, from 0 to @ref bcalcDDS_getPlayedCardsCount "bcalcDDS_getPlayedCardsCount(solver)"-1
@param suit place to save suit (if not NULL), one of BCALC_SUIT_*
@param cardSymbol place to store card symbol (if not NULL)
@return
- @c 1 only if card with given index was played,
- @c 0 if index is larger than @ref bcalcDDS_getPlayedCardsCount "bcalcDDS_getPlayedCardsCount(solver)"-1
 (error is not set in such situation and @p suit and @p cardSymbol are not changed).
*/
extern int bcalcDDS_getPlayedCard(BCalcDDS* solver, unsigned whenIndex, int* suit, char* cardSymbol);

/**
Get number of cards which have been already played.
@param solver bcalc double dummy solver
@return number of cards which have been already played
*/
extern int bcalcDDS_getPlayedCardsCount(BCalcDDS* solver);

#ifdef __cplusplus
}
#endif

#endif	//__BELING__BCALC_BRIDGE_SOLVER__
