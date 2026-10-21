import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { isPageOnlyLanguage } from '../../../../src/lib/locale';
import { carrierMetadata, CarrierRoute } from '../../../../src/server/carrierPages';

type Params = Promise<{ language: string; slug: string }>;

export async function generateMetadata({ params }: { params: Params }): Promise<Metadata> {
  const { language, slug } = await params;
  return isPageOnlyLanguage(language) ? carrierMetadata(language, slug) : {};
}

/**
 * A carrier's page in a language with pages alone, such as Finnish for Posti, for anyone, whatever
 * language the browser prefers: its text in that language, everything around it in English. The site's
 * own languages have folders of their own, which come first; any other language, any other slug, and a
 * carrier not written in that language, is the site's 404.
 */
export default async function PageOnlyCarrierPage({ params }: { params: Params }) {
  const { language, slug } = await params;
  if (!isPageOnlyLanguage(language)) notFound();
  return <CarrierRoute locale={language} slug={slug} />;
}
