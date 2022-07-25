/* Last non-groff version: hpoint.c  1.1  84/10/08 */

/*
 * This file contains routines for manipulating the point data
 * structures for the gremlin picture editor.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdlib.h>
#include "gprint.h"

/* imports from main.cpp */
extern void *grnmalloc(size_t size, const char *what);

/*
 * Return pointer to empty point list.
 */
POINT *
PTInit()
{
  return ((POINT *) NULL);
}


/*
 * This routine creates a new point with coordinates x and y and links
 * it into the point list.
 */
POINT *
PTMakePoint(double x,
	    double y,
	    POINT **pplist)
{
  POINT *pt;

  if (Nullpoint(pt = *pplist)) {	/* empty list */
    *pplist = (POINT *) grnmalloc(sizeof(POINT), "initial point");
    pt = *pplist;
  } else {
    while (!Nullpoint(pt->nextpt))
      pt = pt->nextpt;
    pt->nextpt = (POINT *) grnmalloc(sizeof(POINT), "subsequent point");
    pt = pt->nextpt;
  }

  pt->x = x;
  pt->y = y;
  pt->nextpt = PTInit();
  return (pt);
}				/* end PTMakePoint */

// Local Variables:
// fill-column: 72
// mode: C++
// End:
// vim: set cindent noexpandtab shiftwidth=2 textwidth=72:
