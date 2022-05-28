void HorizontalGoto(DviWidget, int);
void VerticalGoto(DviWidget, int);
void VerticalMove(DviWidget, int);
void FlushCharCache(DviWidget);
void Newline(DviWidget);
void Word(DviWidget);
int PutCharacter(DviWidget, char *);
void PutNumberedCharacter(DviWidget, int);
void DrawLine(DviWidget, int, int);
void DrawCircle(DviWidget, int);
void DrawFilledCircle(DviWidget, int);
void DrawEllipse(DviWidget, int, int);
void DrawFilledEllipse(DviWidget, int, int);
void DrawArc(DviWidget, int, int, int, int);
void DrawPolygon(DviWidget, int *, int);
void DrawFilledPolygon(DviWidget, int *, int);
void DrawSpline(DviWidget, int *, int);

