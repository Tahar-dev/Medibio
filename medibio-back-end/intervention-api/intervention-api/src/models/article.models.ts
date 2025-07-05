// article.schema.ts

import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({
  toJSON: {
    transform: function (doc, ret) {
      const ordered = {};
      const fieldOrder = [
        '_id', 'id', 'parcid', 'designation', 'us',
        'quantity', 'type', 'ref', 'commentaire', '__v'
      ];

      fieldOrder.forEach(key => {
        if (ret[key] !== undefined) {
          ordered[key] = ret[key];
        }
      });

      return ordered;
    }
  }
})
export class Article {

  @Prop({ type: String })
  _id: string; // <-- ajoute ceci pour forcer un _id de type string !

  @Prop({ required: false })
  id: string;

  @Prop({ required: false })
  parcid: string;

  @Prop({ required: false })
  designation: string;

  @Prop({ required: false })
  us: string;

  @Prop({ required: false })
  quantity: string;

  @Prop({ required: false })
  type: string;

  @Prop({ required: false })
  ref: string;

  @Prop({ required: false })
  commentaire: string;
}

export type ArticleDocument = Article & Document;

export const ArticleSchema = SchemaFactory.createForClass(Article);

// optionnel : pour éviter un champ virtuel "id" de mongoose
ArticleSchema.set('id', false);
